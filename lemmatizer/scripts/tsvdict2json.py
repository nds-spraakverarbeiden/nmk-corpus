import sys,os,re,argparse,json,traceback

args=argparse.ArgumentParser(description=""" 
	read dictionary in TAB format, e.g., LEMMA<TAB>POS<TAB>DESCR.
	note that we merge akin to consolidate-vocab.py""")
lemma_column=0
args.add_argument("-l", "--lemma_column", type=int, help=f"LEMMA column, defaults to {lemma_column}", default=lemma_column)
args.add_argument("-n", "--norm_column", type=int, help="NORM column, defaults to LEMMA column", default=None)
args.add_argument("-f", "--form_column", type=int, help="FORM column (original orthography), defaults to NORM column", default=None)
args.add_argument("-p", "--pos_column", type=int, help="POS column, if not provided, POS defaults to _", default=None)
args.add_argument("-pf", "--posfeat_column", type=int, help="column containing POS and FEATS, if not provided, extrapolated from POS value", default=None)
args.add_argument("-d", "--descr_columns", type=int, nargs="*", help="description column(s), by default all columns not covered by the other column IDs", default=None)

args.add_argument("files", type=str, nargs="*", help="files to read from, defaults to stdin", default=None)
args=args.parse_args()
if args.norm_column==None: 
	args.norm_column=args.lemma_column
	sys.stderr.write(f"set norm_column to {args.norm_column}\n")

if args.form_column==None:
	args.form_column=args.norm_column

src="_"
files=args.files
if len(files)==0 or files==None:
	sys.stderr.write("reading from stdin\n")
	files=[sys.stdin]

pos2feats={
	"NOUN": "Nom.Sg",
	"VERB": "Inf",
	"ADJ": "Pos.Pred",
	"NOUN.Masc": "Nom.Sg",
	"NOUN.Fem": "Nom.Sg",
	"NOUN.Neut": "Nom.Sg",
	"NOUN.Pl": "Nom",
	}

entry2feats2norm2form2src2texts={}
for file in files:
	if isinstance(file,str): 
		sys.stderr.write(f"reading from {file}\n")
		src=file
		file=open(file,"rt",errors="ignore")
	sys.stderr.flush()
	for line in file:
		sys.stderr.flush()
		if len(line.strip())>0: 
			try:
				fields=line.split("\t")
				form=fields[args.form_column]
				lemma=fields[args.lemma_column]
				norm=fields[args.norm_column]
				splitter=",()!"
				for s in splitter:
					if s in form:
						if len(form.split(s)[0].strip())>0: 
							form=form.split(s)[0].strip()
						else:
							form=form.split(s)[1].strip()
					if s in norm:
						if len(norm.split(s)[0].strip())>0: 
							norm=norm.split(s)[0].strip()
						else:
							norm=norm.split(s)[1].strip()
				form=form.strip()
				norm=norm.strip()
				if form=="": form="_"
				if norm=="": norm=form

				pos="_"
				if args.pos_column!=None:
					pos=fields[args.pos_column]

				if args.posfeat_column!=None:
					base_pos=pos
					pos=fields[args.posfeat_column]
				else:
					base_pos=pos # excl. features
					#if "." in base_pos: base_pos=base_pos.split(".")[0]

				descr=[]
				if args.descr_columns!=None:
					descr=[f for n,f in enumerate(fields) if n in args.descr_columns ]
				else:
					descr=[ f for n,f in enumerate(fields) if not n in [args.lemma_column,args.norm_column,args.pos_column,args.form_column,args.posfeat_column]]
				entry=lemma
				if pos!="_":
					entry+="/"+base_pos
				feats=lemma+"/"+pos
				if pos in pos2feats:
					feats+="."+pos2feats[pos]
				if not "." in pos:
					for p in pos2feats:
						if p in pos: # this allows additional characters, e.g., ?
							feats+="."+pos2feats[p]
							break
				if "?" in feats.split("/")[-1]:
					feats="/".join(feats.split("/")[0:-1])+"/"+"".join(feats.split("/")[-1].split("?"))+"?"
				text="\t".join(descr).strip()
				if not entry in entry2feats2norm2form2src2texts: 
					entry2feats2norm2form2src2texts[entry]={}
				if not feats in entry2feats2norm2form2src2texts[entry]: 
					entry2feats2norm2form2src2texts[entry][feats]={}
				if not norm in entry2feats2norm2form2src2texts[entry][feats]: 
					entry2feats2norm2form2src2texts[entry][feats][norm]={}
				if not form in entry2feats2norm2form2src2texts[entry][feats][norm]: 
					entry2feats2norm2form2src2texts[entry][feats][norm][form]={}
				if not src in entry2feats2norm2form2src2texts[entry][feats][norm][form]: 
					entry2feats2norm2form2src2texts[entry][feats][norm][form][src]=[]
				if not text in entry2feats2norm2form2src2texts[entry][feats][norm][form][src]:
					entry2feats2norm2form2src2texts[entry][feats][norm][form][src].append(text)
				#print(fields)
				#print(entry,feats,norm,form,src,text)
				#print()
			except Exception:
				# print(pos)
				traceback.print_exc()
				sys.stderr.write(f"warning: could not process split line \"{fields}\"\n")
	file.close()

result={}
for entry in sorted(entry2feats2norm2form2src2texts):
	result[entry]={}
	for feats in sorted(entry2feats2norm2form2src2texts[entry]):
		result[entry][feats]={}
		for norm in sorted(entry2feats2norm2form2src2texts[entry][feats]):
			result[entry][feats][norm]={}
			for form in sorted(entry2feats2norm2form2src2texts[entry][feats][norm]):
				result[entry][feats][norm][form]={}
				for src in sorted(entry2feats2norm2form2src2texts[entry][feats][norm][form]):
					result[entry][feats][norm][form][src]=sorted(entry2feats2norm2form2src2texts[entry][feats][norm][form][src])

json.dump(result,sys.stdout)