import re,os,sys,argparse,json

#
# aux functions
#

vowel_umlaut=[ 	("a", "e"), ("o" , "ö"), ("u","ü"), 
			 	("å","œ"), ("å","Ä"), 	# form hängt vom zeitpunkt des umlauts ab
			 	("O","Ö"), ("U","Ü"),
			 	("ä","e"),				# for ar- and an-dialects
			 	("au","äu") 			# cautious: we must prohibit *aü
			 ]

consonant=r"[bdfghjklmnprstvwxS]"

def simplify_lemma(lemma:str):
	""" simplify lemma for annos
		i.e., drop derivation information
		this is highly specific to our corpus
	"""

	lemma=re.sub(r"e?n/VERB([-+])","\1",lemma) # in compounds, verbs may loose their ending
	lemma=re.sub(r"/[^+-]*","",lemma)
	lemma="".join(lemma.split("+"))
	if '-"' in lemma:
		for vowel,umlaut in vowel_umlaut:
			if re.match(r"(.*"+consonant+"|')?"+vowel+"("+consonant+')*-"',lemma):
				lemma=re.sub(r"(.*"+consonant+"|')?"+vowel+"("+consonant+')*-"',r"\1"+umlaut+"\2",l)
	lemma="".join(lemma.split("-"))
	lemma="".join(lemma.split("'"))
	return lemma

def to_stacked_dict(list_of_values:list ,d:dict):
	""" add list of values to d such that we first element is top-level key of a dict, etc., final element must be unique, otherwise, we perform "+" """
	if len(list_of_values)<2:
		raise Exception("expect two-element list, at least")

	key=list_of_values[0]
	if len(list_of_values)==2:
		if not key in d: 
			d[key]=list_of_values[1]
		else:
			try: 
				d[key]+=list_of_values[1]
			except e as Exception:
				sys.stderr("ERROR: same key used multiple times; for such data, terminal nodes must support a `+` operation")
				raise e
		return d

	if not key in d: d[key]={}
	d[key]=to_stacked_dict(list_of_values[1:], d[key])

	return d


#
# params
#

args=argparse.ArgumentParser(description="""read full_forms/*curated.tsv files, produce a vocab.json-compliant json file""")
args.add_argument("files", type=str, nargs="*", help="TSV files to read from, if not specified, read from stdin", default=None)
args.add_argument("-w", "--word_col", type=int, help="word column, defaults to 0", default=0)
args.add_argument("-n", "--norm_col", type=int, help="norm column, defaults to 1", default=1)
args.add_argument("-l", "--lemma_col", type=int, help="lemma column, defaults to 2", default=2)
args.add_argument("-m", "--morph_col", type=int, help="morph + feats column, defaults to 3", default=3)
args.add_argument("-f", "--freq_col", type=int, help="freq column (optional), defaults to 4; note that we also support relative frequencies", default=4)
args.add_argument("-feats", "--keep_feats", type=str, nargs="*", help="""feature values to be preserved in LEMMA (in order of occurrence; use this to preserve nominal gender in lexical entries). By default, we keep the first element and assume . as separator symbol.
	If a feature is relevant for certain parts of speech (= 1st feature) only, concatenate part of speech and feature and connect by ., e.g., NOUN.Neut""", default=[])
args.add_argument("-tsv", "--tsv_output", action="store_true", help="spell out TSV for subsequent manual curation")
#args.add_argument("-desyl", "--drop_syllabification", action="store_true", help="if set, remove syllabification symbols")

args=args.parse_args()

if args.files==None or len(args.files)==0:
	sys.stderr.write("reading from stdin\n")
	args.files=[sys.stdin]

max_col=max(args.word_col,args.norm_col,args.lemma_col, args.morph_col)

# this is a "\t"-separated string
head_anno_norm_orth_source2freq={}

for file in args.files:
	source="(stdin)"
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		source=file.split("/")[-1].split(".")[0]
		file=open(file,"rt",errors="ignore")		
	sys.stderr.flush()
	for line in file:
		line=line.split("#")[0].rstrip()
		fields=line.split("\t")
		if len(fields)>max_col:
			fields=[f.strip() for f in fields]
			w=fields[args.word_col]
			if not w in ["","_"]:
				norm=fields[args.norm_col]
				l=fields[args.lemma_col]
				m=fields[args.morph_col]
				freq=1
				try: 
					freq=float(fields[args.freq_col])
				except Exception:
					pass

				# head word: full morphological analysis (as from original LEMMA) "/" TAG ("." + ".".join(args.keep_feats)
				head_lemma=re.sub(r"[()]","",l)

				head_tag=m.split()[0].split(".")[0]
				head_feats=[]
				feat_vals=m.split()[0].split(".")
				for feat in args.keep_feats:
					if not "." in feat or feat.startswith(head_tag+"."):
						myfeat=re.sub(r".*\.","",feat)
						if myfeat in feat_vals:
							head_feats.append(myfeat)
				head=head_lemma+"/"+".".join([head_tag]+ head_feats)

				# anno: simplified lemma "/" + original MORPH
				anno=simplify_lemma(l)+"/"+m
				
				# 	duplicate analysis for lemmas with parentheses
				annos=[anno]
				if re.match(r".*[(][^()]*[)]", anno):
					annos=[re.sub(r"[()]","",anno), re.sub(r"[(][^()]*[)]","",anno)]

				for anno in annos:

					# json format:
					# - head word: full morphological analysis (as from original LEMMA) "/" TAG ("." + ".".join(args.keep_feats)
					# - anno: simplified lemma "/" + original MORPH
					# 		- duplicate analysis for lemmas with parentheses
					# - norm
					# - orth (word)
					# - source
					# - freq

					key="\t".join([head,anno,norm,w,source])
					if not key in head_anno_norm_orth_source2freq:
						head_anno_norm_orth_source2freq[key]=0
					head_anno_norm_orth_source2freq[key]+=freq

	file.close()

if args.tsv_output:
	# TSV output
	for head_anno_norm_orth_source,freq in head_anno_norm_orth_source2freq.items():
		print(head_anno_norm_orth_source+f"\t{freq}")
else:
	# JSON output
	result={}
	for head_anno_norm_orth_source,freq in head_anno_norm_orth_source2freq.items():
		result=to_stacked_dict(head_anno_norm_orth_source.split("\t")+[freq],result)
	#result.sort()

	json.dump(result,sys.stdout)



