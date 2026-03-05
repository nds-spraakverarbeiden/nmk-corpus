import re,sys,os,json,io
import subprocess
from func_timeout import func_timeout, FunctionTimedOut

# wrapper around fst-parse
# implements cascaded lookup
# i.e., consult higher-complexity analyses only if the previous level failed

########
# defs #
########

class Analyzer:

	# todo: flush_cache() to json dict

	fst_parse=None
	minimization_regex=None
	contrastive_features=[	"Nom","Dat","Acc","Gen", 	# case
						  	"Pl",						# number (only plural), note that we match by substring, so this includes Pl_s, etc.
						  	"Masc","Neut","Fem",		# for adjectives (Note: we also get generic neutra, derived via verbs, all the time)
						  	"1","2","3",				# number (pronouns, determiners and verbs)
						  	"Ind", "Prs", "Prt", "Inf", "Inf_to", "PPast", 	# verbal features
						  	"Ind", "Def", "Refl", "Int", "Rel"	# DET and PRON features
						  ]
		# OLD: args.add_argument("-cf","--contrastive_features", type=str, nargs="*", help=f"if minimimize_output, use these as distinctive features, defaults to {contrastive_features}", default=contrastive_features)

	# sub-Analyzers initialized in analyze(infer_form=True) for fst from component[0], used to infer the norm
	form2norm=None 	# first sub-Analyzer
	anno2norm=None	# sub-Analyzer for components[1:]

	def minimize_fst(self, norm_analyses: list, minimize_strictly=False):
		""" norm_analyses is a list of tupels of (norm/'_', analysis) 
			minimization operates with self.minimization_regex
		"""

		minimization_regex=r"." # return the shortest possible string

		if self.minimization_regex!=None: 
			# alternatively, minimize the number of symbols matching the regex, e.g., morpheme separators
			minimization_regex=self.minimization_regex

		contrastive_features=[] # no contrastive features for minimization, compare POSes only
		if self.contrastive_features!=None:
			contrastive_features=self.contrastive_features

		len2norm2analyses={}
		for norm, analysis in norm_analyses:
			l=len(re.findall(minimization_regex,analysis))
			if not l in len2norm2analyses: len2norm2analyses[l]= {}
			if not norm in len2norm2analyses[l]: len2norm2analyses[l][norm]=[]
			if not analysis in len2norm2analyses[l][norm]: len2norm2analyses[l][norm].append(analysis)

		result=[]
		poses=[]
		for l in sorted(len2norm2analyses):
			for norm,analyses in len2norm2analyses[l].items():
				for a in analyses:
					pos=a
					if " " in pos: pos=pos.split(" ")[0]
					if "/" in pos: pos=pos.split("/")[-1]
					if "+" in pos: pos=pos.split("+")[0]
					if "-" in pos: pos=pos.split("-")[0]
					if "." in pos: pos=pos.split(".")[0] # if enabled, we include *all* features, otherwise, POS+contrastive_features
					if contrastive_features!=None and len(contrastive_features)>0:
						for f in contrastive_features:
							if f in a.split(" ")[0].split("/")[-1].split("+")[0].split("-")[0].split("."):
								pos+="."+f
					if not pos in poses:
						result.append((norm,a))
						if not pos in poses:
							poses.append(pos)
			if minimize_strictly: break
		return result

	def get_fst_parser(self):
		if self.method=='fst':
			if self.fst_parse==None: # or self.fst_parse.poll()==None:
				# poll() should return None if the process died for whatever reason
				# but it also does so if it is very much alive ...
				if len(self.components)==0:
					raise Exception("need at least one FST")
				cmd="fst-parse "+" -t ".join(self.components[0:1]+list(reversed(self.components[1:])))
				sys.stderr.write(f"init process with '{cmd}'\n")
				self.fst_parse = subprocess.Popen(['stdbuf', "-i0", "-o1"] + cmd.split(), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=sys.stderr, bufsize=0,universal_newlines=True,shell=False)
				# alternatively, use unbuffer:
				#self.fst_parse = subprocess.Popen(['unbuffer',"-p"] + cmd.split(), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=sys.stderr, bufsize=0,universal_newlines=True,shell=False)
					# to use unbuffer, do sudo apt-get install expect-dev
					# cf. https://stackoverflow.com/questions/2055918/forcing-a-program-to-flush-its-standard-output-when-redirected
				
			return self.fst_parse
		raise Exception("unsupported method, available methods: 'dict', 'fst'")

	def __init__(self,config:dict, minimization_regex=None, contrastive_features=None):
		""" minimizaton regex is a regular expression to match symbols to be counted in minimization.
			this defaults to any character, but we can use it to count morpheme boundaries, etc. 

			contrastive_features is feature values that are relevant during minimization, annotations that don't differ in one contrastive feature or POS are considered equivalent
		"""

		self.minimization_regex=minimization_regex
		
		if contrastive_features==None:
			sys.stderr.write("contrastive_features: "+",".join(self.contrastive_features)+"\n")
		else:
			self.contrastive_features=contrastive_features

		self.method=config['method']
		self.form2norm2parse2score={}
			# for lookup/dict-based annotation, this is our core data structure
			# for more complex annotators, this is an internal cache consulted before calling the annotator
		self.components=config['components']
		self.procs=None
			# processes, initialized from components and method, but only for complex annotators

		######################
		# dict configuration #
		######################

		if self.method=="dict":
			for d in self.components:
				with open(d,"rt", errors="ignore") as input:
					comp=json.load(input)
					for lemma,parse2norm2form2x in comp.items():
						for parse,norm2form2x in parse2norm2form2x.items():
							for norm,form2x in norm2form2x.items():
								for form in form2x:
									if not form in self.form2norm2parse2score: self.form2norm2parse2score[form]={}
									if not norm in self.form2norm2parse2score[form]: self.form2norm2parse2score[form][norm]={}
									if not parse in self.form2norm2parse2score[form][norm]: self.form2norm2parse2score[form][norm][parse]=0
									self.form2norm2parse2score[form][norm][parse]+=1
									# higher scores for recurring elements

		#####################
		# fst-parse wrapper #
		#####################

		elif self.method=="fst":
			pass
		else:
			raise Exception(f"unsupported method {self.method}, use 'dict' or 'fst'")

	def get_norm(self,form,anno=None):
		""" note: norm inference from anno only works if nothing is omitted """

		# first sub-Analyzer
		if self.form2norm==None:
			config={"method":"fst", "components": self.components[0:1] }
			self.form2norm=Analyzer(config, contrastive_features=[], minimization_regex=".")

		# sub-Analyzer for components[1:]
		if anno!=None and self.anno2norm==None:
			config={"method":"fst", "components": list(self.components[1:]) }
			self.anno2norm=Analyzer(config,contrastive_features=[], minimization_regex=".")

		wordnorms_min=self.form2norm.analyze(word,infer_norm=False,minimize_fst=True)
		wordnorms=[n for _,n in wordnorms_min ]
		
		if not anno in [None,"_",""]:
			annonorms_min=self.anno2norm.analyze(anno,infer_norm=False,minimize_fst=True)
			if annonorms_min!=None:
			
				print("YAY",word,anno,wordnorms_min,annonorms_min)
				sys.exit()

				annonorms=[n for _,n in annonorms_min ]

				for w in wordnorms:
					if w in annonorms:
						return w

				wordnorms_max=self.form2norm.analyze(word,infer_norm=False,minimize=False)
				wordnorms=[n for _,n in wordnorms_max ]
				for w in wordnorms:
					if w in annonorms:
						return w

				annonorms_max=self.anno2norm.analyze(anno,infer_norm=False,minimize=False)
				annonorms=[n for _,n in annonorms_max ]
				for w in wordnorms:
					if w in annonorms:
						return w

				if len(wordnorms_min)>0:
					wordnorms=[n for _,n in wordnorms_min ] # otherwise, max

		# prefer wordnorms with fewer long vowels, this is specific to our corpus ...		
		if len(wordnorms)==0:
			return "_"  # can happen due to timeouts ... unlikely

		wordnorms=sorted(set(wordnorms))
		cand=wordnorms[0]
		long_chars=len(re.sub(r"[a-gi-uw-zöüS]","",cand))	# we embrace S, but avoid h, because this may be lengthening, we also avoid v for cases in which it can be w
		for w in wordnorms[1:]:
			long_chars_w=len(re.sub(r"[a-gi-uw-zöüS]","",w))
			if long_chars_w<long_chars or (long_chars_w==long_chars and len(w)<len(cand)):
				cand=w
				long_chars=long_chars_w
		
		return cand

	def analyze(self,word:str, minimize_fst=True, keep_syllables=False, infer_norm=True, minimize_strictly=False, timeout=None):
		if not timeout:
			return self._analyze(word,minimize_fst,keep_syllables,infer_norm,minimize_strictly)

		try:
			return func_timeout(timeout, self._analyze,args=[word,minimize_fst,keep_syllables,infer_norm,minimize_strictly])
		except FunctionTimedOut:
			pass

		if infer_norm:
			try:
				return [(func_timeout(1, self.get_norm, args=[word]),"_")] # 1 sec
			except FunctionTimedOut:
				pass

		return [("_","_")]

	def _analyze(self,word:str, minimize_fst=True, keep_syllables=False, infer_norm=True, minimize_strictly=False):
		""" returns list of norm (or '_') and annotation 
			if infer_norm is true, extrapolate norm from successful fst parses
			normally, minimize_fst returns the minimal result(s) for every morphosyntactic analysis
			minimze_strictly returns minimal results overall
		"""

		if minimize_strictly: minimize_fst=True

		original_word=word		# to preserve the original spelling, e.g., for case-sensitive methods

		# dict/cache-based annotation
		if not word in self.form2norm2parse2score:
			word=word.lower() 			# fsts are also case-insensitive ...
		if word in self.form2norm2parse2score:
			score_norm_parses=[]
			for norm,parse2score in self.form2norm2parse2score[word].items():
				for parse,score in parse2score.items():
					score_norm_parses.append((score,norm,parse))
			result = [ (norm,parse) for _,norm,parse in reversed(sorted(score_norm_parses))]
			
			# fst-parse
			# Note: we only need to minimize here
		elif self.method=='fst':
			fst_parser=self.get_fst_parser()
			fst_parser.stdin.write(word+"\n\n")
			fst_parser.stdin.flush()

			result=[]
			while(len(result)==0 or (result[-1].strip()!="" and not '""' in result[-1].strip())):
				result.append(fst_parser.stdout.readline())
				# sys.stderr.write(f"read {result[-1]}")
			if len(result)>1: result=result[:-1]
			result=[re.sub(r"[?]","",line.strip()) for line in result if line.strip()!=""]
			result=[re.sub(r".ocr","",line.strip()) for line in result if line.strip()!=""]
			result=[re.sub(r"^(PRON|DET)[^/]*/\1", r"\1/\1",line) for line in result ]

			if len(result)==1 and result[0].startswith("no analysis for"):
				return None

			result=[("_",res) for res in sorted(set(result))]

			if minimize_fst:
				result=self.minimize_fst(result,minimize_strictly=minimize_strictly)

			if infer_norm:
				result=[ (norm,anno) 
						 if not norm.strip() in ["","_"] 
						 else (self.get_norm(word,anno),anno)
						 for norm,anno in result ]

			word=original_word
			if not word in self.form2norm2parse2score: self.form2norm2parse2score[word]={}
			for norm,parse in result:
				if not norm in self.form2norm2parse2score[word]: self.form2norm2parse2score[word][norm]={}
				if not parse in self.form2norm2parse2score[word][norm]: 
					self.form2norm2parse2score[word][norm][parse]=1/len(result)
				else:
					self.form2norm2parse2score[word][norm][parse]=max(1/len(result),self.form2norm2parse2score[word][norm][parse])
		else:
			return 

		# drop syllable boundaries
		if not keep_syllables:
			tmp=[ ("".join(norm.split("'")), analysis) for norm,analysis in result ]
			result=tmp

		# dedup
		result_dict={ norm+":"+analysis : (norm,analysis) for norm,analysis in result }
		result=sorted(list(result_dict.values()))

		return result

####################
# interactive part #
####################

def help():
	sys.stderr.write(f"""Perform cascaded lookup and FST analyses on one-word-per-line input\nsynopsis: {sys.argv[0]} config.json [-t TIMEOUT] [-c CACHE.JSON] [-syll] [-w INT] [-n] [-min [REGEX]] [-mmin [REGEX]] [-h]

	config.json   configuration file. i.e., an array of different analysis strategies
	              each entry has two keys: 'method': 'dict' or 'fst', and
	                                       'components': list of json dict files (for 'dict') or stacked fst transducers (for 'fst')
	              during lookup, we apply methods in the specified order until an analysis has been found or we encounter a timeout
	              Note that we support an extended json format that allows for #-marked comments, see parser.conf for details
	-c CACHE.JSON if specified, write all results into CACHE.JSON (structure compatible with vocab.json)
	-t TIMEOUT    maximum analysis time for a word in nanoseconds
 	-w INT        when processing TSV/CoNLL input, this is the column to read words from, defaults to 0 (1st col)
 	-n            infer norms (disabled by default, because it may be time-consuming)
	-syll         spell out syllable boundaries (dropped by default, not fully reliable)
	-min [REGEX]  minimize FST output in terms of the number of elements matched by REGEX, e.g., '.' for any character
	-mmin [REGEX] like -min, but return fewer results
	-h            print this message\n""")
	sys.stderr.flush()
	sys.exit()

if len(sys.argv)<=1:
	help()

if "-h" in sys.argv[1:]:
	help()

word_column=0
if "-w" in sys.argv[1:]:
	try:
		word_column=int(sys.argv[1:][sys.argv[1:].index("-w")+1])
	except Exception:
		sys.stderr.write(f"error: invalid argument for flag -w while executing \""+' '.join(sys.argv)+"\"\n")
		help()

# cache
cache=None
if "-c" in sys.argv[1:]:
	try:
		cache=sys.argv[sys.argv.index("-c")+1]
		sys.argv=sys.argv[0:sys.argv.index("-c")]+sys.argv[sys.argv.index("-c")+2:]
	except Exception:
		sys.stderr.write(f"error: invalid argument for flag -c while executing \""+' '.join(sys.argv)+"\"\n")
		help()

timeout=None
if "-t" in sys.argv[1:]:
	try:
		timeout=int(sys.argv[sys.argv.index("-t")+1])
		sys.argv=sys.argv[0:sys.argv.index("-t")]+sys.argv[sys.argv.index("-t")+2:]
	except Exception:
		sys.stderr.write(f"error: invalid argument for flag -t while executing \""+' '.join(sys.argv)+"\"\n")
		help()

keep_syllables=False
if "-syll" in sys.argv[1:]:
	keep_syllables=True
	sys.argv=sys.argv[0:sys.argv.index("-syll")]+sys.argv[sys.argv.index("-syll")+1:]

infer_norm=False
if "-n" in sys.argv[1:]:
	infer_norm=True
	sys.argv=sys.argv[0:sys.argv.index("-n")]+sys.argv[sys.argv.index("-n")+1:]

# evaluate as last, because its following argument is optional
minimize_strictly=False
minimize=False
minimization_regex=None
if "-mmin" in sys.argv[1:]:
	minimize_strictly=True
	sys.argv[sys.argv.index("-mmin")]="-min"
if "-min" in sys.argv[1:]:
	minimize=True
	try:
		minimization_regex=sys.argv[1:][sys.argv[1:].index("-min")+1]
		sys.argv=sys.argv[0:sys.argv.index("-min")]+sys.argv[sys.argv.index("-min")+2:]
	except Exception:
		sys.argv=sys.argv[0:sys.argv.index("-min")]+sys.argv[sys.argv.index("-min")+1:]

########
# init #
########

with open(sys.argv[1],"rt",errors="ignore") as input:
	json_text=re.sub(r"^#[^\n]*","",re.sub(r"([^\\])#[^\n]*",r"\1",input.read()))
	config=json.loads(json_text)

contrastive_features=Analyzer.contrastive_features
sys.stderr.write("contrastive_features: "+",".join(contrastive_features)+"\n")

analyzers=[ Analyzer(c,minimization_regex=minimization_regex, contrastive_features=contrastive_features) for c in config ]

word2norm2anno2srces={}

if cache!=None:
	if os.path.exists(cache):
		with open(cache,"rt",errors="ignore") as input:
			lemma_pos2anno2norm2word2srces=json.load(input)
			for lemma_pos,anno2norm2word2srces in lemma_pos2anno2norm2word2srces.items():
				lemma=lemma_pos.split("/")[0]
				for anno, norm2word2srces in anno2norm2word2srces.items():
					for norm,word2srces in norm2word2srces.items():
						for word,srces in word2srces.items():
							if not word in word2norm2anno2srces: word2norm2anno2srces[word]={}
							if not norm in word2norm2anno2srces[word]: word2norm2anno2srces[word][norm]={}
							if not anno in word2norm2anno2srces[word][norm]: word2norm2anno2srces[word][norm][anno]=[]
							for src in srces:
								if not src in word2norm2anno2srces[word][norm][anno]: word2norm2anno2srces[word][norm][anno].append(src)

########
# proc #
########

sys.stderr.write("reading one word per line from stdin\n")
sys.stderr.flush()
for line in sys.stdin:
	line=line.rstrip()
	if line=="":
		print()
		continue

	if "#" in line:
		print("#".join(line.split("#")[1:]))
		line=line.split("#")[0].strip()

	line=line.rstrip()
	if len(line)>0:
		fields=line.split("\t")
		if len(fields)<=word_column:
			sys.stderr.write(f"warning: no word column found in '{line}'\n")
			print(line)
			break

		word=fields[word_column].strip()
		if word=="":
			sys.stderr.write(f"warning: empty word in '{line}'\n")
			print("# "+line)
		else: 
			if not word in word2norm2anno2srces:
				if word.lower() in word2norm2anno2srces:
					word2norm2anno2srces[word]=word2norm2anno2srces[word.lower()]
				else:
					for a in analyzers:
						analyses=a.analyze(word,minimize_fst=minimize,keep_syllables=keep_syllables,infer_norm=infer_norm,minimize_strictly=minimize_strictly,timeout=timeout)
						if analyses and len(analyses)>0:
							for norm,anno in analyses:
								srces=[a.method+":"+"+".join(a.components)]
								if not word in word2norm2anno2srces: word2norm2anno2srces[word]={}
								if not norm in word2norm2anno2srces[word]: word2norm2anno2srces[word][norm]={}
								if not anno in word2norm2anno2srces[word][norm]: word2norm2anno2srces[word][norm][anno]=[]
								for src in srces:
									if not src in word2norm2anno2srces[word][norm][anno]: word2norm2anno2srces[word][norm][anno].append(src)
							break

			if not word in word2norm2anno2srces:
				word2norm2anno2srces[word]={"_": {"_":["_"]}}

			for norm,anno2srces in word2norm2anno2srces[word].items():
				for anno,srces in anno2srces.items():
					analysis=fields+[norm,anno,"|".join(sorted(set(srces)))]
					print("\t".join(analysis))
					fields=["*"]*len(fields)


if cache!=None:
	lemma_pos2anno2norm2word2srces={}
	for word, norm2anno2srces in word2norm2anno2srces.items():
		for norm,anno2srces in norm2anno2srces.items():
			for anno,srces in anno2srces.items():
				lemma_pos=anno.split(".")[0] # for getting the POS, old way for pronouns and determiners
				if "/" in anno: 
					lemma="/".join(anno.split("/")[:-1])
					pos=anno.split("/")[-1].split(".")[0]
					lemma_pos=lemma+"/"+pos
				if not lemma_pos in lemma_pos2anno2norm2word2srces: lemma_pos2anno2norm2word2srces[lemma_pos]={}
				if not anno in lemma_pos2anno2norm2word2srces[lemma_pos]: lemma_pos2anno2norm2word2srces[lemma_pos][anno]={}
				if not norm in lemma_pos2anno2norm2word2srces[lemma_pos][anno]: lemma_pos2anno2norm2word2srces[lemma_pos][anno][norm]={}
				if not word in lemma_pos2anno2norm2word2srces[lemma_pos][anno][norm]: lemma_pos2anno2norm2word2srces[lemma_pos][anno][norm][word]=[]
				for src in srces:
					if not src in lemma_pos2anno2norm2word2srces[lemma_pos][anno][norm][word]: lemma_pos2anno2norm2word2srces[lemma_pos][anno][norm][word].append(src)
	with open(cache,"wt",errors="ignore") as output:
		json.dump(lemma_pos2anno2norm2word2srces,output)