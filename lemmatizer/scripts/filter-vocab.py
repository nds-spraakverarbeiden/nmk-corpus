import sys,os,re,json
from pprint import pprint

""" import ../morph/forms/*conll,
	fill in gaps, 
	filter out analyses with clitics,
	retrieve phonological forms,
	infer phonological forms for lemma candidates, 
	filter lemma candidates by plausibility,
	"""

files=[os.path.join("../morph/forms/", file) for file in os.listdir("../morph/forms/") if file.endswith("conll") ]
if len(sys.argv)>1:
	files=sys.argv[1:]

src2form2norm2morph={}

for src in files:
	sys.stderr.write(f"processing {src}\n")
	sys.stderr.flush()
	last_fields=None
	with open(src,"rt",errors="ignore") as input:
		src2form2norm2morph[src]={}
		for line in input:
			line=line.rstrip()
			try:
				fields=line.split("\t")

				if last_fields != None:
					for x in range(len(fields)-1): # we keep morph
						if fields[x] in ["_","*",""]: 
							consistent=True
							for lf,f in zip(last_fields[:x],fields):
								if lf!=f: 
									consistent=False
									break
							if consistent:
								fields[x]=last_fields
					last_fields=fields

				form=fields[0]
				pos=fields[1]
				norm=fields[2]
				split=fields[3] 	# IGNORED: clitics split off
				lookup=fields[4] 	# IGNORED: lookup split forms, for clitics, this often contains the correct analysis
				morph=fields[5]		# morphological candidate analyses, note that this may be an analysis of a clitic rather than the main word, only, so
									# so, limit to cases that have the same tag as the main word, the clitics should be covered by lookup
									# note that morph annotation is independent from fields[3:5]

				if not " " in norm: # skip clitics
					if morph!="_" and re.sub(r".*/","",morph).startswith(pos):
						if not form in src2form2norm2morph[src]: src2form2norm2morph[src][form]={}
						if not norm in src2form2norm2morph[src][form]: src2form2norm2morph[src][form][norm]=[]
						if not morph in src2form2norm2morph[src][form][norm]: src2form2norm2morph[src][form][norm].append(morph)

			except Exception:
				pass

# max probability per form
lemma_pos2maxP={}

# this is for calculating avgP, initially, this is a list, we avg in the end
lemma_pos2avgP={}
for src in src2form2norm2morph:
	for form in src2form2norm2morph[src]:
		morphs=[]
		for norm in src2form2norm2morph[src][form]:
			for morph in src2form2norm2morph[src][form][norm]:
				if not morph in morphs:
					morphs.append(morph)
		morphs=[ re.sub(r"\.[^/]*$","",m) for m in morphs ]
		for morph in morphs:
			p=len([m for m in morphs if m == morph ])/len(morphs)
			if not morph in lemma_pos2maxP: 
				lemma_pos2maxP[morph]=p
				lemma_pos2avgP[morph]=[]
			lemma_pos2maxP[morph]=max(lemma_pos2maxP[morph],p)
			lemma_pos2avgP[morph].append(p)

lemma_pos2avgP={m:sum(ps)/len(ps) for m,ps in lemma_pos2avgP.items() }

lemma_pos_sorted=[l for _,_,l in reversed(sorted([(lemma_pos2maxP[lp], lemma_pos2avgP[lp], lp) for lp in lemma_pos2maxP ]))]

# pruning
lemma_pos2morph2norm2form2src={}
for src in src2form2norm2morph:
	for form in src2form2norm2morph[src]:
		l_p=None
		for norm in src2form2norm2morph[src][form]:
			for morph in src2form2norm2morph[src][form][norm]:
				my_lp=re.sub(r"\.[^/]*$","",morph)
				if l_p==None or (my_lp in lemma_pos_sorted and lemma_pos_sorted.index(my_lp) < lemma_pos_sorted.index(l_p)):
					l_p=my_lp
		if l_p!=None:
			if not l_p in lemma_pos2morph2norm2form2src: lemma_pos2morph2norm2form2src[l_p]={}
			for norm in src2form2norm2morph[src][form]:
				for morph in src2form2norm2morph[src][form][norm]:
					if morph.startswith(l_p):
						if not morph in lemma_pos2morph2norm2form2src[l_p]: lemma_pos2morph2norm2form2src[l_p][morph]={}
						if not norm in lemma_pos2morph2norm2form2src[l_p][morph]: lemma_pos2morph2norm2form2src[l_p][morph][norm]={}
						if not form in lemma_pos2morph2norm2form2src[l_p][morph][norm]: lemma_pos2morph2norm2form2src[l_p][morph][norm][form]=[]
						if not src in lemma_pos2morph2norm2form2src[l_p][morph][norm][form]: lemma_pos2morph2norm2form2src[l_p][morph][norm][form].append(src)

# nun können die lemmas allerdings in *irgendeiner* orthographie sein
# wir ersetzen daher das originale lemma durch die norm derjenigen form, die formal identisch mit dem Lemma sein sollte
old_lemma_pos2morph2norm2form2src=lemma_pos2morph2norm2form2src
lemma_pos2morph2norm2form2src={}
for lp,details in old_lemma_pos2morph2norm2form2src.items():
	if "/" in lp:		
		lemma,pos=lp.split("/")[:2]
		if pos in ["VERB","AUX"]:
			for m in details:
				if re.match(r".*(Inf|Pl.Ind.Prs).*",m):
					lemma=list(details[m])[0] # first norm
					break
			if "(" in lemma:
				for m in details:
					if re.match(r".*(Sg.Imp|1.Sg.Ind.Prs).*",m):
						lemma=list(details[m])[0]+"en?" # first norm
						break
					if re.match(r".*(2.Sg.Ind.Prs).*",m):
						lemma=list(details[m])[0].rstrip("t").rstrip("s")+"n?" # first norm
						break
					if re.match(r".*(Pl.Imp|3.Sg.Ind.Prs).*",m):
						lemma=list(details[m])[0].rstrip("t")+"n?" # first norm
						break
		elif pos in ["NOUN","PROPN"]:
			for m in details:
				if "Nom" in m and not "Pl" in m:
					lemma=list(details[m])[0] # first norm
					break
			if "(" in lemma:
				cand=lemma
				for m in details:
					for n in details[m]:
						if len(n)<len(cand):
							cand=n
				lemma=cand+"?"
		elif pos in ["ADJ"]:
			for m in details:
				if "Nom" in m and "Masc" in m and not "Cpv" in m and not "Spv" in m:
					lemma=list(details[m])[0] # first norm
					break
			if "(" in lemma:
				cand=lemma
				for m in details:
					for cand in details[m]:
						if len(n)<len(cand):
							cand=n
				lemma=cand+"?"
		elif pos in ["ADV"]:
			for m in details:
				if not "Cpv" in m and not "Spv" in m:
					lemma=list(details[m])[0] # first norm
					break
			if "(" in lemma:
				cand=lemma
				for m in details:
					for n in details[m]:
						if len(n)<len(cand):
							cand=n
				lemma=cand+"?"
		elif pos not in ["DET","PRON"]:
			if "(" in lemma:
				cand=lemma
				for m in details:
					for n in details[m]:
						if len(n)<len(cand):
							cand=n
				lemma=cand # no ? because these should be uninflected
		lp=lemma+"/"+pos
	if not lp in lemma_pos2morph2norm2form2src: 
		lemma_pos2morph2norm2form2src[lp]=details
	else:
		for morph in details:
			if not morph in lemma_pos2morph2norm2form2src[lp]: lemma_pos2morph2norm2form2src[lp][morph]={}
			for norm in details[morph]:
				if not norm in lemma_pos2morph2norm2form2src[lp][morph]: lemma_pos2morph2norm2form2src[lp][morph][norm]={}
				for form in details[morph][norm]:
					if not form in lemma_pos2morph2norm2form2src[lp][morph][norm]: lemma_pos2morph2norm2form2src[lp][morph][norm][form]=[]
					for src in details[morph][norm][form]:
						if not src in lemma_pos2morph2norm2form2src[lp][morph][norm][form]: lemma_pos2morph2norm2form2src[lp][morph][norm][form].append(src)
					
lemma_pos2morph2norm2form2src = { l:lemma_pos2morph2norm2form2src[l] for l in sorted(lemma_pos2morph2norm2form2src) }
json.dump(lemma_pos2morph2norm2form2src,sys.stdout)
