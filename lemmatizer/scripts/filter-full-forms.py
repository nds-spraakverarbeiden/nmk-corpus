import sys,os,re,argparse

args=argparse.ArgumentParser(description="""
	Given a RAW analysis in TSV and one or more DICTS (*from_dict.tsv).
	We expect the first column to hold the WORD.
	For every WORD, use the DICT files (all simultaneously).
	Return content from RAW only if no DICT information is available.
	""")
args.add_argument("raw_tsv", type=str, help="RAW analysis in TSV, e.g., full_forms/bornemann-1816-gedichte.full.raw.tsv")
args.add_argument("from_dict_tsv", type=str, nargs="*", help="TSV files from dicts", default=[])
args.add_argument("-cols","--columns", type=int, nargs="*", help="columns to be used for matching, defaults to first column", default=[])
args.add_argument("-c", "--match_case_sensitive", action="store_true", help="perform case-sensitive matching (default: case-insensitive)")
args.add_argument("-no-def", "--disable_defaults", action="store_true", help="""disable defaults for the NMK corpus

	These defaults include:
	- limit NOUN (4th column) to upper case expressions (first column only),
	- drop syllable separators from NORM column (= second column),
	- simplify duplicate consonants at syllable boundaries,
	- limit duplicate comparison to column 1, 3 and 4 (skip norm),
	- splitting last /-separated segment of raw lines into a separate column


	Case-insensitive matching for from_dict.tsv lookup is also a default, but regulated by --match_case_sensitive.

	Note that we don't normalize annotations.
	""")
args=args.parse_args()

cols=args.columns
if cols==None or len(cols)==0:
	cols=[0]
col2entry2lines={ col: {} for col in cols }
col2entry2signatures={ col: {} for col in cols }

for file in args.from_dict_tsv:
	sys.stderr.write(f"reading {file}\n")
	sys.stderr.flush()
	with open(file,"rt",errors="ignore") as input:
		for line in input:
			line=line.split("#")[0].rstrip()
			if "\t" in line:
				forms=line.split("\t")
				for col in cols:
					if len(forms)>col:
						form=forms[col].strip()
						if col==0 and not args.match_case_sensitive:
							form=form.lower()
						if col==1 and not args.disable_defaults:
							form="".join(form.split("'"))							# drop syllable boundaries
							form=re.sub(r"([bdfghjklmnprstvwxS])\1+",r"\1",form) 	# simplify duplicate consonants
						if not form in ["","_"]:
							if not form in col2entry2lines[col]:
								col2entry2lines[col][form]=[]
								col2entry2signatures[col][form]=[]
							signature=line
							if not args.disable_defaults and len(line.split("\t"))>3:
								signature=line.split("\t")[0]+"\t"+line.split("\t")[3]
							if not signature in col2entry2signatures[col][form]:
								col2entry2signatures[col][form].append(signature)
								col2entry2lines[col][form].append(line+"\t"+file)

sys.stderr.write(f"reading {args.raw_tsv}\n")
sys.stderr.flush()
output=[]
with open(args.raw_tsv,"rt", errors="ignore") as input:
	for line in input:
		if "#" in line:
			output.append("#"+"#".join(line.split("#")[1:]))
			line=line.split("#")[0].strip()
		line=line.rstrip()
		if len(line)>0:
			fields=line.split("\t")
			if not args.disable_defaults:
				if "/" in fields[-1]:
					fields.append(fields[-1].split("/")[-1])
					fields[-2]="/".join(fields[-2].split("/")[:-1])
				else:
					fields.append(fields[-1])
				line="\t".join(fields)
			printed=False
			for col in cols:
				if len(fields)>col and not printed:
					form=fields[col].strip()
					if col==0 and not args.match_case_sensitive:
						form=form.lower()
					if col==1 and not args.disable_defaults:
						form="".join(form.split("'"))							# drop syllable boundaries
						form=re.sub(r"([bdfghjklmnprstvwxS])\1+",r"\1",form) 	# simplify duplicate consonants
					if not form in ["","_"]:
						if form in col2entry2lines[col]:
							for l in col2entry2lines[col][form]:
								result=[fields[0]]+l.split("\t")[1:] 	# keep original spelling
								if not "'" in result[1] and "'" in fields[1]:
									result[1]=fields[1]  			# keep syllabification if dict line doesn't have it (as in from_dict.tsv)
								l="\t".join(result)
								output.append(l)
								printed=True
			if not printed:
				output.append(line)	

sys.stderr.write(f"writing\n")
sys.stderr.flush()
for line in output:
	line=line.rstrip()
	if line.startswith("#"): 
		print(line)

output=[l for l in output if not line.startswith("#")]
output=sorted(set(output))

for line in output:
	line=line.rstrip()
	fields=line.split("\t")
	if len(fields)>3 and not args.disable_defaults:
		if fields[3].startswith("NOUN") and fields[0]!=fields[0].upper(): # lower-cased			
			pass
		else:
			print(line)
	else:
		print(line)


