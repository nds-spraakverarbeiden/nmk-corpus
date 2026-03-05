import os,re,sys,argparse,readchar

from datetime import datetime

args=argparse.ArgumentParser(description="simple editor for full form TSV files")
args.add_argument("full_form_tsv", type=str, help="full_form TSV file, entries with four or less columns are subject to editing, everything else not")
args.add_argument("corpus_files", type=str, nargs="+", help="one or more text or CoNLL files to be searched for attestations")

OUTFILE_SUFFIX=datetime.today().strftime('%y-%m-%d')

args.add_argument("-o","--outfile", type=str, help="outfile prefix. defaults to full_form_tsv. the full name consists of prefix and {OUTFILE_SUFFIX}",default=None)

DEFAULT_PROGRESS_MARKER="#### BIS HIER ####"

args.add_argument("-m", "--progress_marker", type=str, help=f"a progress marker is a substring we expect at the beginning of a line. we will not touch anything before that progress marker, and when saving, we will put the progress marker after our last edit, defaults to {DEFAULT_PROGRESS_MARKER}", default=DEFAULT_PROGRESS_MARKER)
args.add_argument("-i", "--ignore_case", action="store_true", help="if set, perform case-insensitive matching")
args.add_argument("-cl", "--clause_level_chunking", action="store_true", help="if set, split at intrasentential punctuation characters to return smaller context windows")



def update_outfile(processed,to_be_processed,outfile,progress_marker=DEFAULT_PROGRESS_MARKER):
	bak=outfile+".bak"

	if os.path.exists(outfile):
		if os.path.exists(bak):
			os.remove(bak)
		os.rename(outfile,bak)
	with open(outfile,"wt",errors="ignore") as outfile:
		if len(processed) > 0:
			for line in processed: 
				outfile.write(line+"\n")
			if len(to_be_processed)>0:
				outfile.write("\n\n"+progress_marker +" "+datetime.now().strftime('%Y-%m-%d %H:%M')+"\n\n")
		if len(to_be_processed)>0:
			for line in to_be_processed:
				outfile.write(line+"\n")

args=args.parse_args()
if args.outfile==None:
	args.outfile=args.full_form_tsv

outfile=args.outfile+"."+OUTFILE_SUFFIX

corpus=[]

while(len(args.corpus_files)>0):
	file=args.corpus_files[0]
	args.corpus_files=args.corpus_files[1:]
	if os.path.isdir(file):
		args.corpus_files+=[ os.path.join(file,sub) for sub in os.path.listdir(file)]
	else:
		with open(file,"rt",errors="ignore") as input:
			for line in input:
				line=line.rstrip()
				if not "\t" in line and len(line)>0:
					if args.clause_level_chunking:
						separators=",;:"
						for sep in separators:
							if sep in line:
								line="\n".join(line.split(sep))

					for clause in line.split("\n"):
						clause=clause.strip()
						if len(clause)>0:
							if " " in clause:
								corpus.append(" "+clause+" ")
							else:
								corpus.append(" "+line.strip()+" ")

processed=[]
to_be_processed=[]

with open(args.full_form_tsv,"rt",errors="ignore") as input:
	marker_found=False
	for line in input:
		line="\t".join( [ field.strip()  for field in line.split("\t") ])
		if len(line)>0:
			if line.startswith(args.progress_marker):
				processed=to_be_processed
				to_be_processed=[]
				marker_found=True
			else:
				to_be_processed.append(line)

for line in processed:
	print(line)

closing=False
while(not closing and not len(to_be_processed)==0):
	line=to_be_processed[0]
	fields=line.split("\t")
	if len(fields) > 4:
		print(line)
		processed.append(line)
		to_be_processed=to_be_processed[1:]
	else:
		word=fields[0]
		search_term=r"([^a-zöäüÖÄÜA-Z0-9])("+word+r")([^a-zöäüÖÄÜA-Z0-9'])"

		print("="*50)
		printed={}
		for line in corpus:
			try:
				if not line in printed:
					if args.ignore_case:
						if re.match(".*"+search_term,line,re.IGNORECASE):
							printed[line]=re.sub(search_term,r"\1\033[1;31m\2\033[0m\3",line,flags=re.IGNORECASE)
					else:
						if re.match(".*"+search_term,line):
							printed[line]=re.sub(search_term,r"\1\033[1;31m\2\033[0m\3",line)
			except re.error:
				pass # reserved characters in search strings
		for _,match in sorted(printed.items()):
			print(match)
		print("-"*50)

		lines=[ l for l in to_be_processed if l.split("\t")[0]==word or (args.ignore_case and l.split("\t")[0].lower()==word.lower()) ]

		words=sorted(set([ l.split("\t")[0] for l in lines ]))
		norms=sorted(set([ l.split("\t")[1] for l in lines ]))
		lemmas=sorted(set([ l.split("\t")[2] for l in lines ]))
		morphs=sorted(set([ l.split("\t")[3] for l in lines ]))

		print("# \033[1m"+", ".join(words)+" ("+", ".join(norms)+")\033[0m")
		print(", ".join(lemmas))
		while len(morphs)>10:
			max_len=max([len(m) for m in morphs])
			morphs=sorted(set([m if len(m)< max_len-3 else m[0:max_len-4]+"..." for m in morphs]))
		print("\n".join(morphs[0:10]))

		newlines=[]

		lastline=""
		options="choose: - (drop line), + (keep line), c (change line), m (add manual line), <DEL> (skip remaining lines)"

		print("\n"+options)
		lines_just_processed=lines
		lines=sorted(set(lines))
		while(len(lines)>0):
			line=lines[0]
			lines=lines[1:]
			sys.stdout.write(line)
			sys.stdout.flush()
			k=None
			while not k in ["-","+","c","m",readchar.key.DELETE]:
				k=readchar.readkey()
			sys.stdout.write("\r"+" "*len("        ".join(line.split("\t")))+"\r")
			sys.stdout.flush()
			if k=="-": 
				continue
			if k=="+":
				print(line)
				newlines.append(line)
				continue
			if k== readchar.key.DELETE:
				print()
				break
			if k in ("c","m"):
				if k=="m":
					lines=sorted(set([line]+lines))
				print(line)
				form,norm,lemma,morph=line.split("\t")

				print()
				while(True):
					sys.stdout.write("revise/confirm norm "+norm+": ")
					sys.stdout.flush()
					newnorm=sys.stdin.readline().strip()
					if newnorm=="": newnorm=norm
					sys.stdout.write("revise/confirm lemma "+lemma+": ")
					sys.stdout.flush()
					newlemma=sys.stdin.readline().strip()
					if newlemma=="": newlemma=lemma
					sys.stdout.write("revise/confirm morph "+morph+": ")
					sys.stdout.flush()
					newmorph=sys.stdin.readline().strip()
					if newmorph=="": newmorph=morph
					newline=form+"\t"+newnorm+"\t"+newlemma+"\t"+newmorph
					print(f"{newline} ok? (Y/n/a[nother variant])")
					k=readchar.readkey()
					if k.lower()=="n":
						continue
					elif k.lower()=="a":
						print(newline)
						newlines.append(newline)
						try:
							form,norm,lemma,morph=newline.split("\t")[0:4]
							continue
						except Exception:
							sys.stderr.flush()
							traceback.print_exc()
							sys.stderr.write("while processing "+str(newline.split('\t'))+"\n")
							sys.stderr.flush()
					else:
						print(newline)
						newlines.append(newline)
						print("\n"+options)
						break

		print("\nconfirmed analyses\n"+"\n".join(sorted(set(newlines))))
		print("ok? (Y/n)")
		if readchar.readkey().lower()=="n":
			continue
		else:
			processed+=newlines
			to_be_processed=[l for l in to_be_processed if not l in lines_just_processed ]

			update_outfile(processed,to_be_processed,outfile,progress_marker=args.progress_marker)

update_outfile(processed,to_be_processed,outfile,progress_marker=args.progress_marker)
