import sys,os,re, argparse, json, traceback, sfst_transduce

#######
# aux #
#######

# aux routines
def get_closest_key_value(key:str,key2value:dict, splitter="."):
	""" find the string key with the max number of splitter-sepearated elements, return its value """

	if len(key2value)==0:
		return ""
	if key in key2value:
		return key2value[key]

	# candidates: short over long, then alphabetical
	candidates=[ key for _,key in sorted([ (len(key),key) for key in key2value.keys() ])]

	candidate=candidates[0]
	max_overlap=0
	for c in candidates:
		overlap=len(set(key.split(splitter)).intersection(c.split(splitter)))
		if overlap>max_overlap:
			candidate=c
			max_overlap=overlap

	return key2value[candidate]

'''
Jamiel Rahi
GPL 2019

A simple implementation of the Levenshtein distance algorithm.

In short: 
* We're comparing strings a and b 
* n = len(a), m = len(b)
* Construct an (n+1) by (m+1) matrix
* Elements (i,j) of the matrix satisfy the following :
	if min(i,j) == 0, lev(i,j) == max(i,j)
	else lev(i,j) = min of  
						lev(i-1,j) + 1, 
						lev(i,j-1) + 1, 
						lev(i-1,j-1) + (1 if a[i-1] != b[j-1])
* lev(n,m) is the levenshtein distance           
'''

import numpy as np

# ratio returns the levenshtein ratio instead of levenshtein distance
# print_matrix prints the matrix
# lowercase compares the strings as lowercase

def levenshtein(a,b,ratio=False,print_matrix=False,lowercase=False) :
	if type(a) != type('') :
		raise TypeError('First argument is not a string!')
	if type(b) != type('') :
		raise TypeError('Second argument is not a string!')
	if a == '' :
		return len(b)
	if b == '' :
		return len(a)
	if lowercase :
		a = a.lower()
		b = b.lower()

	n = len(a)
	m = len(b)
	lev = np.zeros((n+1,m+1))

	for i in range(0,n+1) :
		lev[i,0] = i 
	for i in range(0,m+1) :
		lev[0,i] = i

	for i in range(1,n+1) :
		for j in range(1,m+1) :
			insertion = lev[i-1,j] + 1
			deletion = lev[i,j-1] + 1
			substitution = lev[i-1,j-1] + (1 if a[i-1]!= b[j-1] else 0)
			lev[i,j] = min(insertion,deletion,substitution)

	if print_matrix :
		print(lev)

	if ratio :
		return (n+m-lev[n,m])/(n+m)
	else :
		return lev[n,m]

########
# init #
########

args=argparse.ArgumentParser(description="""
	read full form dictionary as produced by lemmatizer, return the most elementary analyses, write into a JSON dict
	note that we expect all forms in one line, and a TSV format with FORM<TAB>ANALYSES, where ANALYSES uses / and - as separators.
	We return a TSV dictionary with FORM, empty string and PARSE (empty string instead of NORM) to be processed like a CoNLL file for subsequent enrichment.""")
args.add_argument("files",type=str,nargs="*", default=[], help="one or more files produced by lemmatizer")
args.add_argument("-d","--dicts",type=str,nargs="*",default=[], help="one or more JSON dictionaries for NORMs and as a factor for disambiguation. Note that this generally doesn't include all inflected forms. Optionally, every file can be followed by a filter for sources, a regular expression separated by :, e.g., '.*bornemann-1810.*' for ../morph/forms/bornemann-1810-gedichte.full.conll; this is run against keys or elements at embedding depth 5; NOTE: you should put the filter into double quotes, e.g., '-d dict/vocab.json:\".*born.*1810.*\"")
args.add_argument("-t2n","--text2norm", type=str, default=None, help="compiled SFST transducer (*.a) to map text to normalized text, will be used to reconstruct the norm")
args.add_argument("-n2a","--norm2anno", type=str, default=None, help="compiled SFST transducer (*.a) to map normalized text to annotations, will be run in inverted mode to reconstruct the norm")
args.add_argument("-desyl","--desyllabify", action="store_true", help="if set, use desyllabification routine specific to the NMK corpus lemmatizer.")
args.add_argument("-resyl","--resyllabify", action="store_true", help="if set, use resyllabification routine specific to the NMK corpus lemmatizer.")
args=args.parse_args()

if args.resyllabify and args.desyllabify:
	raise Exception("-resyllabify and -desyllabify must not both be set")

text2norm=args.text2norm
norm2anno=args.norm2anno

if text2norm!=None:
	text2norm=sfst_transduce.Transducer(text2norm)

if norm2anno!=None:
	norm2anno=sfst_transduce.Transducer(norm2anno)

#############
# functions #
#############

def desyllabify(norm):
	""" this is specific to our pipeline, with reconstruct_norm(), we actually produce syllabified readings, but the dictionary doesn't have them, so we drop them for the sake of consistency """
	norm=re.sub(r"([bdfghjklmnprstvwxS])'\1",r"\1",norm)
	norm="".join(norm.split("'"))
	return norm


def resyllabify(word,norm_desyl,text2norm=None):
	""" our dictionary doesn't have syllabification, we infer this heuristically """
	t_norms=text2norm.analyse(word)
	if len(t_norms)==0:
		return word
		
	norms=[]
	min_lev=None

	# levenshtein-closest norm(s)
	for t in t_norms:
		lev=levenshtein(norm_desyl,t)
		if min_lev==None or lev < min_lev:
			norms=[]
			min_lev=lev
		if lev==min_lev:
			norms.append(t)

	# limit to shortest strings
	min_len=min([len(n) for n in norms])
	norms=[n for n in norms if len(n)==min_len]

	return norms[0]

def reconstruct_norm(word,anno=None, text2norm=None, norm2anno=None):
	t_norms=[]
	a_norms=[]
	if text2norm!=None:
		t_norms=text2norm.analyse(word)

	if len(t_norms)==1:
		return t_norms[0]

	if norm2anno!=None and anno!=None:
		a_norms=norm2anno.generate(anno)
	
	norms=t_norms
	if len(norms)==0:
		norms=a_norms
	elif len(a_norms)>0:
		norms=[ n for n in a_norms if n in t_norms ]
		if len(norms)==0:
			min_lev=None
			
			# retrieve the closest match			
			for t in t_norms:
				for a in a_norms:
					lev=levenshtein(a,t)
					if min_lev==None or lev < min_lev:
						norms=[]
						min_lev=lev
					if lev==min_lev:
						norms.append(t)

	# fallback for symbols, numbers, etc.
	if len(norms)==0:
		return word

	# limit to shortest strings
	min_len=min([len(n) for n in norms])
	norms=[n for n in norms if len(n)==min_len]

	# return the alphabetically first
	return sorted(norms)[0]

def normalize_inflection_feats(inf:str):
				inf="+".join(f.split(" ")) # different strategies to split clitics
				
				if "/" in inf: inf=f.split("/")[-1]		# (morph features of) last morpheme
				if "+" in inf: inf=f.split("+")[0] 		# applies only to clitic DET and PRON

				# normalize order
				inf=sorted(set(inf.split(".")))

				# filter uppercase or numerical annotations, drop anything after _, drop "?"
				inf=[ "".join(i.split("_")[0].split("?"))
					  for i in inf 
					  if not i in ["","_"] and not i[0] in "abcdefghijklmnopqrstuvwxyz" 
					  ]

				# add "?" for unattested lemmas
				if "?" in f:
					inf.append("?")

				cases=["Nom","Gen","Dat","Acc"]
				genders=["Masc","Fem","Neut"]
				numbers=["Sg","Pl"]

				# drop gender of plurals
				if "Pl" in set(inf):
					for g in genders:
						if g in inf:
							inf.remove(g)

				# drop gender of nouns (=> we keep the highest-scored gender only)
				if "NOUN" in set(inf):
					for g in genders:
						if g in inf:
							inf.remove(g)

				# drop Gender, Case and Number from adverbs (this is an error in the morphology)
				if "ADV" in set(inf):
					for x in cases+genders+numbers:
						if x in inf:
							inf.remove(x)

				# flatten inf
				inf=".".join(inf)

				return inf


# from dicts
form2norm2annos={}
for d in args.dicts:
	filter=r".*"
	if not os.path.exists(d):
		if ":" in d and os.path.exists(d.split(":")[0]):
			filter=":".join(d.split(":")[1:])
			d=d.split(":")[0]
	with open(d,"rt",errors="ignore") as input:
		lem2anno2norm2form2src=json.load(input)
		for lem in lem2anno2norm2form2src:
			for anno in lem2anno2norm2form2src[lem]:
				for norm in lem2anno2norm2form2src[lem][anno]:
					try:
						for form in lem2anno2norm2form2src[lem][anno][norm]:
							for src in lem2anno2norm2form2src[lem][anno][norm][form]:
								if re.match(filter,src):
									norm_anno=anno
									if len(norm_anno.split("/"))==2:
										norm_anno=lem.split("/")[0]+"/"+norm_anno.split("/")[1]
									if not form in form2norm2annos: form2norm2annos[form]={}
									if not norm in form2norm2annos[form]: form2norm2annos[form][norm]=[]
									if not norm_anno in form2norm2annos[form][norm]: form2norm2annos[form][norm].append(norm_anno)
					except:
						traceback.print_exc()
						sys.stderr.write("while processing "+norm+"\n")
						sys.exit()



# from files
form_dict={}

files=args.files
if len(files)==0:
	sys.stderr.write("reading from stdin\n")
	files=[sys.stdin]

analyses=[]
for file in files:
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		file=open(file,"rt",errors="ignore")
	sys.stderr.flush()
	for line in file:
		if "\t" in line:
			line=line.strip()
			fields=line.split("\t")
			word=fields[0]
			feats=re.sub(r'",\s*"',"\t",re.sub(r"\s+"," ",fields[1]))
			score_feat=[]
			for feat in feats.split("\t"):
				feat=feat.strip().strip('"').strip()

				# score: the higher, the better

				# unanalyzed: score=0
				score=0

				# analyzed: score>0
				if not feat in ["_",""]:

					# prefer non-compounds over compounds, e.g., erger-nis over ergern+Is
					stems=len(re.sub(r"[^+]*","",feat))+1
					
					# count morphemes, prefer analyses with fewer morphemes
					affixes=len(re.sub(r"[^/]*","",feat))

					score=1/(1+stems*100+affixes)

					if feat.startswith("?"):
						score=score/1000

				score_feat.append((score,feat))
			
			score_feat.sort()
			score_feat.reverse()

			infs=[]
			inf2norm={}

			# prefer dict information over lemmatizer
			form=word
			if not word in form2norm2annos and word.lower() in form2norm2annos:
				form=word.lower()
			if form in form2norm2annos:
				for norm in form2norm2annos[form]:
					for anno in form2norm2annos[form][norm]:
						analysis=f"{word}\t{norm}\t{anno}"	
						if args.resyllabify:
							analysis=f"{word}\t{resyllabify(word,norm,text2norm=text2norm)}\t{anno}"
						if not analysis in analyses:
							print(analysis)
							analyses.append(analysis)

						inf=normalize_inflection_feats(anno)
						if not inf in inf2norm:
							inf2norm[inf]=norm

			# lemmatizer, plausibility-ranked
			for s,f in score_feat:
				inf=normalize_inflection_feats(f)

				if not inf in infs and not inf in inf2norm: # otherwise, skip, because there is a higher-ranked element with the same inflectional features

					if not "?" in inf or len(infs)+len(inf2norm)==0 or (len(inf2norm)==0 and "?" in infs[0]): # remove questionable analyses if anything plausible is there, already
						norm=get_closest_key_value("".join(inf.split("?")),inf2norm)
						if norm!="" and args.resyllabify:
							norm=resyllabify(word,norm,text2norm=text2norm)

						if norm=="" and len(f.split("/"))==2:
							pos=f.split("/")[1].split(".")[0]
							if pos in [ "ADP", "ADV", "CCONJ", "INTJ", "PART", "PUNCT", "SCONJ", "X"]:
								norm=f.split("/")[0]
						if norm=="":
							norm=reconstruct_norm(word,anno=f, text2norm=text2norm, norm2anno=norm2anno)
							if args.desyllabify:
								norm=desyllabify(norm)

						f="".join(f.split("?"))
						analysis=f"{word}\t{norm}\t{f}"	
						if not analysis in analyses:
							print(analysis)
							analyses.append(analysis)
						infs.append(inf)

	file.close()
