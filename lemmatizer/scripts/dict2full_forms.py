import sys,os,re,argparse,traceback,json

		# TODO: replicate resyllabify/desyllabify from consolidate-full-forms.py


args=argparse.ArgumentParser(description="""
		Given curated full form files (a) and JSON dicts (b):
		- use curated full form file to extrapolate alternative analyses to be added to those in JSON dicts
			- this will be only applied if no explicit form for those analyses is available (for the current selection of sources)
		- export dict content confidence scores as JSON dict or full form TSV file
		- inference and export can be filtered to selected sources, e.g., for certain regions (e.g., -s '(bornemann|danneil)' for Altmark)

		This is primarily intended to extend the coverage of dict/vocab.json, because this was limited to plausible analyses, only, without exhaustiveness checks.
		As a result, the manual verification of full_forms can be limited to forms not covered by the extended vocab files.
		""")


class MorphNormalizer:

	def __init__(self):
		self.norm2morph2freq={}

	def _split(self, morph:str):
		""" split into pos [first tag], feats [uppercase annotations, standardized], flags [lowercase annotations, not standardized] """
		morphs=morph.split(".")
		pos=morphs[0]
		feats=[ m for m in morphs[1:] if len(m)>0 and m[0]==m[0].upper() ]
		flags=[ m for m in morphs[1:] if len(m)>0 and not m in feats and m!="_" ]
		return pos,feats,flags

	def gloss2lemma(self,gloss:str):
		gloss="+".join(gloss.strip().split())
		if "-" in gloss:
			result="-".join( [ self.gloss2lemma(g) for g in gloss.split("-") ])
		elif "+" in gloss:
			result="+".join( [ self.gloss2lemma(g) for g in gloss.split("+") ])
		else:
			result=gloss.split("/")[0]
			if not "/" in gloss:
				result=gloss.split(".")[0]
		return result

	def gloss2morph(self, gloss:str): 
		morph=" ".join([ re.sub(r".*/","",g) for g in gloss.split() ])
		return morph

	def get_flags(self, gloss_or_morph:str):
		morph=gloss_or_morph
		if "/" in morph:
			morph=self.gloss2morph(morph)
		mNorm=self.normalize_morph(morph,keep_flags=True,update_stats=False,keep_order=False)
		_,_,flags=self._split(mNorm)
		return flags

	def normalize_morph(
			self,
			morph:str, 
			keep_flags=False, 	# set to True to preserve lower-case features, note that these are informative only, and not standardized
			update_stats=True, 	# set to False to prevent updating internal statistics for canonicize_morph. This is default in canonicization mode to ensure consistency.
			keep_order=False 	# set to True to preserve original order of feats and flags, however, in the output, feats will be placed before flags
		):
		""" normalize_morph is context-free and guarantees a consistent normalization, but if there is any data to train on, use canonicize_morph(), instead, to (largely) preserve sequential order """
		orig_morph=morph
		morph="".join(morph.split("?"))
		morph=re.sub(r"[\s\+]+"," ",morph)
		for m in list(morph.split()):
			m=m.strip()
			if len(m)>0 and not m=="_" and not "clit" in m:
				morph=m
				break
		if " " in morph:
			morph=morph.split()[0]

		pos,feats,flags=self._split(morph)
		
		if not keep_order:
			feats=sorted(set(feats))
			flags=sorted(set(flags))

		result=[pos]+sorted(set(feats))
		if keep_flags:
			result+=sorted(set(flags))

		result=".".join(result)

		if update_stats:
			if not result in self.norm2morph2freq: self.norm2morph2freq[result]={}
			if not orig_morph in self.norm2morph2freq[result]: self.norm2morph2freq[result][orig_morph]=0
			self.norm2morph2freq[result][orig_morph]+=1

		return result

	def transform_morph(self, 
			source_morph_or_gloss: str, # an existing gloss
			target_nMorph: str, 		# 
			keep_source_flags=True		# keep flags from source_morph
			):
		""" transform a given morph (or gloss) to a canonical representation of the target nMorph """
		
		flags=[]

		if keep_source_flags:
			morph=source_morph_or_gloss
			if "/" in morph: 
				morph=self.gloss2morph(morph)
			nMorph=self.normalize_morph(morph,keep_flags=True,update_stats=False)
			_,_,flags=me._split(nMorph)

		result=self.canonicize_morph(target_nMorph,keep_flags=False)

		if len(flags)>0:
			result+="."+".".join(flags)

		return result

	def canonicize_morph(
			self,
			morph:str,
			keep_flags=True # note that lower-case flags are just preserved and re-ordered, but not canonised
		):
		""" for a morph or a normalized morph, return the canonicized version """
		
		norm=self.normalize_morph(morph,update_stats=False,keep_flags=False)
		result=self.normalize_morph(morph,update_stats=False,keep_flags=False,keep_order=True) # we don't reorder unless we get some evidence
		
		freq=0
		if norm in self.norm2morph2freq:
			for cand,cand_freq in self.norm2morph2freq[norm].items():
				if cand_freq>freq:
					result=cand
					freq=cand_freq
				if cand_freq==freq and len(cand)<len(result):
					result=cand

		if keep_flags:
			_,_,flags=self._split(self.normalize_morph(morph,update_stats=False,keep_flags=False,keep_order=False))
			if len(flags)>0:
				result=result+"."+".".join(flags)

		return result

if __name__ == "__main__":

	args.add_argument("jdicts", type=str, nargs="+", help="JSON dicts for conversion")
	args.add_argument("-tsv", "--curated_tsv_files", type=str, nargs="*", 
		help="""curated TSV files, 
			columns: 
			FORM SYLL LEMMA MORPH;
			this is used for inferring additional morphological analyses,
			if missing, we only convert and normalize the output
			""",
		default=[])
	
	cutoff_default=0.5
	args.add_argument("-c","--cutoff",type=float, help=f"cutoff value for scores, defaults to {cutoff_default}", default=cutoff_default)
	
	no_inference_poses=["DET","PRON", "AUX", "ADP", "PART","_", "INTJ","CCONJ","NUM"]
	args.add_argument("-dont","--pos_without_inference", type=str, help=f"POSes for which no inference is to be done, defaults to "+",".join(no_inference_poses), default=no_inference_poses)	
	args.add_argument("-d", "--disable_defaults", action="store_true", help="disable default inferences for NMK corpus (this includes capitalization normalization and inference of alternative grammatical analyses)")
	args.add_argument("-t", "--run_tests", action="store_true", help="instead of running the application, perform consistency tests")
	args.add_argument("-j", "--export_json_dict", action="store_true", help="if enabled, export json dict; otherwise, export a full_form tsv file")
	args.add_argument("-s", "--source_limit_regex", type=str, help="regular expression to limit to specific sources in jdicts, e.g., '.*/born.* for bornemann'; by default None", default=r".*")
	args=args.parse_args()

	if not args.source_limit_regex.startswith("^") and not args.source_limit_regex.startswith(r".*"):
		args.source_limit_regex=r"^.*"+args.source_limit_regex

	me=MorphNormalizer()

	file2form2morph2norm={} # norm: normalized morphology

	for file in args.curated_tsv_files:
		sys.stderr.write(f"reading {file}\n")
		with open(file,"rt",errors="ignore") as input:
			sys.stderr.flush()
			form2morph2norm={}
			for nr,line in enumerate(input):
				line=line.split("#")[0].strip()
				try:
					fields=line.split("\t")
					fields=[f.strip() for f in fields]
					form,syll,lemma,morph=fields[:5]
					if not "ocr" in morph and not "?" in morph and morph[0] in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
						if not form in form2morph2norm: form2morph2norm[form]={}
						if not morph in form2morph2norm[form]: form2morph2norm[form][morph]=me.normalize_morph(morph)
				except Exception as e:
					sys.stderr.write("ERROR: "+str("\n".join(e.args))+" ")
					# traceback.print_exc()
					sys.stderr.write(f"while processing line {nr+1}:\n\"{line}\"\n\n")
					sys.stderr.flush()
		file2form2morph2norm[file]=form2morph2norm

	norm2norm2score={}
	if len(file2form2morph2norm)>0:
		norm2norm2freq={}
		norm2freq={}
		for file in file2form2morph2norm:
			for form in file2form2morph2norm[file]:
				norms=set(file2form2morph2norm[file][form].values())
				for n in norms:
					if not n in norm2freq: norm2freq[n]=0
					norm2freq[n]+=1
					if len(norms)>1:
						for m in norms:
							if m != n:
								if not m in norm2norm2freq: norm2norm2freq[m]={}
								if not n in norm2norm2freq[m]: norm2norm2freq[m][n]=0
								norm2norm2freq[m][n]+=1
		for norm in norm2norm2freq:
			norm2norm2score[norm]={}
			for norm2,freq in norm2norm2freq[norm].items():
				score=freq/norm2freq[norm]
				if score>=args.cutoff:
					if  args.pos_without_inference==None or \
						len(args.pos_without_inference)==0 or \
						not norm.split(".")[0] in args.pos_without_inference or \
						not norm2.split(".")[0] in args.pos_without_inference:
						norm2norm2score[norm][norm2]=score


	lemma2mNorm2gloss2norm2string2src={}

	for file in args.jdicts:
		sys.stderr.write(f"reading {file}\n")
		sys.stderr.flush()
		with open(file,"rt",errors="ignore") as input:
			jdict=json.load(input) # todo: use consolidate-vocab.py, instead. this is more robust against duplicates
			for lemma in jdict:
				mNorm2gloss2norm2string2src={}
				if lemma in lemma2mNorm2gloss2norm2string2src: 
					mNorm2gloss2norm2string2src=lemma2mNorm2gloss2norm2string2src[lemma]
				for orig_gloss in jdict[lemma]:
					gloss=orig_gloss
					if "(" in gloss and "/" in lemma:
						gloss=lemma.split("/")[0]+"/"+"/".join(gloss.split("/")[1:])
					morph=me.gloss2morph(gloss)
					mNorm=me.normalize_morph(morph,update_stats=False)
					for norm in jdict[lemma][orig_gloss]:
						for form in jdict[lemma][orig_gloss][norm]:
							for src in jdict[lemma][orig_gloss][norm][form]:
								if re.match(args.source_limit_regex, src):
									if not mNorm in mNorm2gloss2norm2string2src:
										mNorm2gloss2norm2string2src[mNorm]={}
									if not gloss in mNorm2gloss2norm2string2src[mNorm]: 
										mNorm2gloss2norm2string2src[mNorm][gloss]={}
									if not norm in mNorm2gloss2norm2string2src[mNorm][gloss]: 
										mNorm2gloss2norm2string2src[mNorm][gloss][norm]={}
									if not form in mNorm2gloss2norm2string2src[mNorm][gloss][norm]: 
										mNorm2gloss2norm2string2src[mNorm][gloss][norm][form]=[]
									if not file in mNorm2gloss2norm2string2src[mNorm][gloss][norm][form]:
										mNorm2gloss2norm2string2src[mNorm][gloss][norm][form].append(file)
									if not src in mNorm2gloss2norm2string2src[mNorm][gloss][norm][form]: 
										mNorm2gloss2norm2string2src[mNorm][gloss][norm][form].append(src)
				if len(mNorm2gloss2norm2string2src)>0:
					lemma2mNorm2gloss2norm2string2src[lemma]=mNorm2gloss2norm2string2src

	result={}

	warnings=[]
	for lemma in sorted(lemma2mNorm2gloss2norm2string2src):
		# note that this lemma is the lemma of the main word, but it clitics apply, these won't be included
		# this is why we extract the lemma from the gloss, too

		mNorm2score={}
		mNorm2gloss2norm2string2src2score={}
		for mNorm in lemma2mNorm2gloss2norm2string2src[lemma]:
			mNorm2score[mNorm]=1.0
			mNorm2gloss2norm2string2src2score[mNorm]=\
				{ re.sub(r"^([A-Z]+)/\1",r"\1",me.gloss2lemma(gloss)+"/"+me.canonicize_morph(me.gloss2morph(gloss))): 
				    { norm :
				      { string:
				        { src : mNorm2score[mNorm]
				          for src in lemma2mNorm2gloss2norm2string2src[lemma][mNorm][gloss][norm][string]
				        }
				      	for string in lemma2mNorm2gloss2norm2string2src[lemma][mNorm][gloss][norm]
				      }
				      for norm in  lemma2mNorm2gloss2norm2string2src[lemma][mNorm][gloss]
				    }
				  	for gloss in lemma2mNorm2gloss2norm2string2src[lemma][mNorm]
				}

			orig_mNorm=mNorm

			if not mNorm in norm2norm2score and not args.disable_defaults:
				pos2feat2unless= {
					"NOUN": {
						"Sg": r"Pl.*",
						"Nom": r"(Gen|Acc|Dat)"
						},
					"PROPN": {
						"Sg": r"Pl.*",
						"Nom": r"(Gen|Acc|Dat)",
						"Masc": r"(Top|Fem|Neut)"
					},
					"ADJ": {
						"Pred" : r"(Nom|Acc|Dat|Gen|Sg|Pl)",
						"Pos": r"(Cpv|Spv)"
					},
					"VERB": {
						"Inf" : r"(Ind|Spv|Imp|1|2|3|Sp|Pl|PPast|PPres)"
					},
					"AUX": {
						"Inf" : r"(Ind|Spv|Imp|1|2|3|Sp|Pl|PPast|PPres)"
					}
				}
				mNorms=[mNorm]
				for pos in pos2feat2unless:
					if pos in mNorm:
						for feat,unless in pos2feat2unless[pos].items():
							for x in sorted(set(mNorms)):
								if unless!=None or not re.matches(unless,x):
									revised=x+"."+feat
									mNorms.append(me.normalize_morph(revised,update_stats=False))
				mNorms=[ m for m in mNorms if m in norm2norm2score ]
				if len(mNorms)>0:
					mNorm=mNorms[0]

			if not mNorm in norm2norm2score and not args.disable_defaults:
				if mNorm.split(".")[0] in ("NOUN","PROPN","PRON"): 
					if not ".Pl" in mNorm:
						mNorm=me.normalize_morph(mNorm+".Sg",update_stats=False,keep_flags=True)
					if not ".Nom" in mNorm and not ".Dat" in mNorm and not ".Acc" in mNorm and not ".Gen" in mNorm:
						mNorm=me.normalize_morph(mNorm+".Nom",update_stats=False,keep_flags=True)

			if not mNorm in norm2norm2score:
				if not mNorm in ["_", "", "O","-"]:
					warning=f"WARNING: {mNorm} not in norm2norm2score ("+",".join(sorted(set([n.split(".")[0]+"..." for n in norm2norm2score])))+")\n"
					if not warning in warnings:
						sys.stderr.write(warning)
						warnings.append(warning)

			if mNorm in norm2norm2score:
				for mNorm2,score in norm2norm2score[mNorm].items():
					if not mNorm2 in lemma2mNorm2gloss2norm2string2src[lemma]:
						#sys.stderr.write(f"DEBUG: adding {mNorm2} to {lemma} with score {score}\n")
						if not mNorm2 in mNorm2score or score>mNorm2score[mNorm2]:
							mNorm2score[mNorm2]=score
							mNorm2gloss2norm2string2src2score[mNorm2]= \
								{ re.sub(r"^([A-Z]+)/\1",r"\1",me.gloss2lemma(gloss)+"/"+me.transform_morph(gloss,mNorm2)): 
								    { norm :
								      { string:
								        { src : mNorm2score[mNorm2]
								          for src in lemma2mNorm2gloss2norm2string2src[lemma][orig_mNorm][gloss][norm][string]
								        }
								      	for string in lemma2mNorm2gloss2norm2string2src[lemma][orig_mNorm][gloss][norm]
								      }
								      for norm in  lemma2mNorm2gloss2norm2string2src[lemma][orig_mNorm][gloss]
								    }
								  for gloss in lemma2mNorm2gloss2norm2string2src[lemma][orig_mNorm]
								}

			if not args.disable_defaults:
				
				# limit PROPN to upper case
				# enforce NOUN upper case
				# create lowercase variants for everything else
				for mNorm in list(mNorm2gloss2norm2string2src2score):
					pos=mNorm.split(".")[0]
					for gloss in list(mNorm2gloss2norm2string2src2score[mNorm]):
						for norm in list(mNorm2gloss2norm2string2src2score[mNorm][gloss]):
							for string in list(mNorm2gloss2norm2string2src2score[mNorm][gloss][norm]):
								warning=""
								if pos in ["PROPN"]:
									if string[0]!=string[0].upper():
										warning=f"dropping non-uppercased PROPN {string}"
										mNorm2gloss2norm2string2src2score[mNorm][gloss][norm].pop(string)
								else:
									string_norm=string
									if pos in ["NOUN"]:
										string_norm=string[0].upper()+string[1:]
									elif not pos in ["INTJ"] and not " "in string:
										string_norm=string.lower()

									if string_norm!=string:
										if not string_norm in mNorm2gloss2norm2string2src2score[mNorm][gloss][norm]: 
											mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string_norm] = mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string]
										else:
											for src, score in list(mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string].items()):
												if not src in mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string_norm] or \
													mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string_norm][src] < score:
													mNorm2gloss2norm2string2src2score[mNorm][gloss][norm][string_norm][src]=score

										warning=f"normalize case for {mNorm.split('.')[0]} {string} > {string_norm}"
										mNorm2gloss2norm2string2src2score[mNorm][gloss][norm].pop(string)

								if warning!="" and not warning in warnings:
									warnings.append(warning)
									sys.stderr.write("WARNING: "+warning+"\n")
									sys.stderr.flush()

		result[lemma]={}

		for gloss2norm2string2src2score in mNorm2gloss2norm2string2src2score.values():
			for gloss,norm2string2src2score in gloss2norm2string2src2score.items():
				if not gloss in result[lemma]: result[lemma][gloss]={}
				for norm, string2src2score in norm2string2src2score.items():
					if not norm in result[lemma][gloss]: result[lemma][gloss][norm]={}
					for string,src2score in string2src2score.items():
						if not string in result[lemma][gloss][norm]: result[lemma][gloss][norm][string]={}
						for src,score in src2score.items(): 
						 	if not src in result[lemma][gloss][norm][string] or result[lemma][gloss][norm][string][src]<score:
						 		result[lemma][gloss][norm][string][src]=score

	if args.run_tests:
		function2input_outputs={
			me._split:
				[ ("DET.Def.Sg.Nom.clit", ("DET",["Def","Sg","Nom"],["clit"])) ],
			me.gloss2lemma:
				[ ("Peter/PROPN.Masc.Nom.Sg", "Peter"),
				  ("DET.Def.Sg.Nom.clit", "DET") ],
			me.normalize_morph:
				[ ("DET.Def.Sg.Nom.clit", "DET.Def.Nom.Sg") ,
				  ("Peter/PROPN.Masc.Nom.Sg", "PROPN.Masc.Nom.Sg") ],
			me.canonicize_morph:
				[ ("DET.Def.Sg.Nom.clit", None)] 	# depends on the input TSV
		}

		function2errors={}
		for function in function2input_outputs:
			for input,gold in function2input_outputs[function]:
				print(f"testing {function.__name__}({input}) .. ",end="")
				try:
					if isinstance(input,tuple): 
						output=function(*input)
					else: 
						output=function(input)
					if gold!=None:
						gold=str(gold)
						output=str(output)
						if not function in function2errors:
							function2errors[function]=0
						if gold==output:
							print("OK")
						else:
							print("FAIL")
							print("GOLD:", gold)
							function2errors[function]+=1
					print("OUT: ",output)
				except Exception:
					print()
					sys.stdout.flush()
					sys.stderr.flush()
					traceback.print_exc()
					sys.stderr.flush()
				print()

		for function in function2errors:
			print(f"{function.__name__}: FAIL {int(function2errors[function]*10000/len(function2input_outputs[function]))/100}% ({function2errors[function]}/{len(function2input_outputs[function])}")
		sys.exit()

	elif args.export_json_dict:
		json.dump(result,sys.stdout)

	else: 
		# export full form TSV: FORM NORM LEMMA MORPH SCORE SRC
		# note that this makes sense only for a single source (or author)
		# TODO: warning about that
		# TODO: filter by source(s) **when reading in the dictionary** (!)
		lines=[]
		form2norm2lemma2morph2score={}
		for lemma,gloss2norm2string2src2score in sorted(result.items()):
			for gloss,norm2string2src2score in sorted(gloss2norm2string2src2score.items()):

				# some function words have no actual LEMMA, so, we take the POS, instead
				word_formation=gloss.split(".")[0]
				inflection=gloss

				# for words with lemma
				if "/" in gloss: 
					inflection=gloss.split("/")[-1]
					word_formation="/".join(gloss.split("/")[0:-1])
					if "clit" in inflection.split()[0] and len(word_formation)>0:
						inflection=word_formation.split(" ")[-1].split("/")[-1]+" "+inflection
						if "/" in word_formation.split(" ")[-1]:
							word_formation=" ".join(word_formation.split(" ")[:-1])+"/"+word_formation.split(" ")[-1].split("/")[:-1]
					if len(word_formation)==0:
						if "/" in inflection:
							word_formation=inflection.split("/")[0]
							inflection="/".join(inflection.split("/")[1:])
						else:
							word_formation=inflection.split(".")[0]

				for norm, form2src2score in sorted(norm2string2src2score.items()):
					norm=re.sub(r"[+-?]+","",norm)
					for form, src2score in sorted(form2src2score.items()):
						score,src=list(reversed(sorted([ (sc, sr) for sr,sc in src2score.items()])))[0]

						#line=f"{form}\t{norm}\t{lemma} > {word_formation}\t{gloss} > {inflection}\t{score}\t{src}"
						line=f"{form}\t{norm}\t{word_formation}\t{inflection}\t{score}\t{src}"
						print(line)
