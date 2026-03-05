import sys,os,re,argparse

RESERVED_CHARACTERS=".!()*,-:?+_=&"


args=argparse.ArgumentParser(description="read dictionary in TAB format, e.g., <FORM><TAB><LEMMA<TAB>POS. Create an FST file that performs lookup-based replacement")
args.add_argument("FST",type=str,help="output file, must not exist")
args.add_argument("dicts", type=str, nargs="*", help="dictionaries in TSV format, defaults to stdin", default=None)
args.add_argument("-s", "--source_col", type=int, help="source column, numbered from 0")
args.add_argument("-t", "--target_cols", type=int, nargs="+", help="target columns, numbered from 0")
args.add_argument("-sep", "--separator", type=str, help="separator for annotations when multiple columns are to be combined, defaults to /", default="/")
args.add_argument("-f", "--freq_col", type=int, help="use frequencies, if provided; entails --disambiguate", default=None)
args.add_argument("--disambiguate", action="store_true", 
				help="""perform frequency-based disambiguation; 
						without -f, we count occurrences; 
						with equal frequency for the compound value of -t, use decreasing frequency for values of individual columns from left to right;
						with equal frequencies, return the first""")
args=args.parse_args()

def disambiguate(vals:list,val2freq):
	""" return the vals with the highest value according to val2freq """
	result=vals
	score=None
	for val in vals:
		freq=0
		if val in val2freq:
			freq=val2freq[val]
		if score==None or freq>score:
			result=[]
			score=freq
		if score==freq and not val in result:
			result.append(val)
	return result

if args.freq_col!=None:
	args.disambiguate=True

src2tgt2freq={}
tgt2freq={}		# for compound values, concatenated by args.separator
col2tgt2freq={}	# for individual values from target columns
tgt2tgts={}

max_col=max(args.source_col,max(args.target_cols))

if args.dicts==None or len(args.dicts)==0:
	sys.stderr.write("reading from stdin\n")
	args.dicts=[sys.stdin]

for file in args.dicts:
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		file=open(file,"rt",errors="ignore")
	sys.stderr.flush()
	for line in file:
		line=line.split("#")[0].strip()
		fields=line.split("\t")
		if len(fields)>max_col:
			src=fields[args.source_col].strip()
			if not src in src2tgt2freq: src2tgt2freq[src]={}
			tgts=[ fields[tgt_col] for tgt_col in args.target_cols ]
			freq=1
			if args.freq_col!=None and len(fields)>args.freq_col:
				try: 
					freq=float(fields[args.freq_col]) # we actually support relative frequencies, too, ... but don't mix them up with absolute freqs!
				except Exception:
					pass
			tgt=args.separator.join(tgts)
			
			if not tgt in tgt2tgts:
				tgt2tgts[tgt]=tgts

			if not tgt in src2tgt2freq[src]: 
				src2tgt2freq[src][tgt]=freq
			else: 
				src2tgt2freq[src][tgt]+=freq

			if not tgt in tgt2freq:
				tgt2freq[tgt]=freq
			else:
				tgt2freq[tgt]+=freq

			for col,tgt in zip(args.target_cols,tgts):
				if not col in col2tgt2freq: col2tgt2freq[col]={}
				if not tgt in col2tgt2freq[col]:
					col2tgt2freq[col][tgt]=freq
				else:
					col2tgt2freq[col][tgt]+=freq

	file.close()

result=[]
for src in src2tgt2freq:
	tgts=src2tgt2freq[src].keys()
	
	if args.disambiguate:
		tgts=disambiguate(tgts,src2tgt2freq[src])
		for nr,col in enumerate(args.target_cols):
			if len(tgts)<=1: 
				break
			cand2freq={}
			for cand in tgts:
				freq=0
				if cand in tgt2tgts:
					key=tgt2tgts[cand][nr]
					if key in col2tgt2freq[col]:
						freq=col2tgt2freq[col][key]
				cand2freq[cand]=freq
			tgts=disambiguate(tgts,cand2freq)
		tgts=[tgts[0]]

	for c in RESERVED_CHARACTERS:
		if c in src:
			if c==src:
				src="\\"+c
			elif c in src:
				src=f"\\{c}".join(src.split(c))

	for tgt in tgts:
		for c in RESERVED_CHARACTERS:
			if c==tgt:
				tgt="\\"+c
			elif c in tgt:
				tgt=f"\\{c}".join(tgt.split(c))

#		if len(set(RESERVED_CHARACTERS) & set(tgt+src))>0:
#			sys.stderr.write(f"warning: skip replacement \"{src}\" > \"{tgt}\" because it contains a reserved character from {RESERVED_CHARACTERS}\n")
#			sys.stderr.flush()
#			continue
		result.append(f"{{{tgt}}}:{{{src}}}")

print("| \\\n".join(result))