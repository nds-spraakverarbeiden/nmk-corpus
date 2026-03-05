import sys,os,re,json,argparse

args=argparse.ArgumentParser(description="""read JSON dicts as used here for dictionaries, 
	then, create a transducer for normalized forms and analyses""")
args.add_argument("dicts", type=str,nargs="+", help="vocab.json-style dict files")
args.add_argument("-syll","--keep_syllabification", action="store_true", help="keep syllabification (default: drop it)")
args=args.parse_args()

dicts=[]
for file in args.dicts:
	if isinstance(file,str):
		sys.stderr.write(f"reading json from {file}\n")
		file=open(file,"rt",errors="ignore")
	sys.stderr.flush()
	dicts.append(json.load(file))
	file.close()

form_analysis=[]

for d in dicts:
	for entry in d:
		if not "/" in entry:
			for analysis in d[entry]:
				for form in d[entry][analysis]:
					form_analysis.append((form,analysis))
		else:
			base_form = entry.split("/")[0]
			for analysis in d[entry]:
				forms = d[entry][analysis].keys()
				if "/" in analysis:
					analysis=base_form+"/"+analysis.split("/")[-1]
					for form in forms:
						if not args.keep_syllabification:
							form="".join(form.split("'"))
						form_analysis.append((form,analysis))
		sys.stderr.write(f"\rextracted {len(form_analysis)} entries")
		sys.stderr.flush()
sys.stderr.write("\n")

forms=set([f.split(".")[0] for f,a in form_analysis ])

form2analyses={}
for n,(form,analysis) in enumerate(form_analysis):
	if "?" in analysis: analysis="".join(analysis.split("?"))

	replacements={"-":"\\-", "+":"\\+","?":"\\?","_":"\\_", ",":"\\,", "(":"\\(", ")":"\\)", "=":"\\="}
	for s,t in replacements.items():
		if s in form: form=t.join(form.split(s))
		if s in analysis: analysis=t.join(analysis.split(s))

	norm="".join(form.split("?"))
	if norm.split(".")[0] in forms: form=norm
		# we limit uncertainties to cases in which the underlying form is not unambiguously confirmed by any dict
	if not form in form2analyses: form2analyses[form]=[]
	if not analysis in form2analyses[form]: form2analyses[form].append(analysis)
	sys.stderr.write(f"\rprocessed {n+1} entries")
	sys.stderr.flush()
sys.stderr.write("\n")

entries=[]
for form in form2analyses:
	for analysis in form2analyses[form]:
		entries.append("{"+analysis+"}:{"+form+"}")
	sys.stderr.write(f"\rinfer {len(entries)} rules")
	sys.stderr.flush()
sys.stderr.write("\n")
sys.stderr.flush()

entries.sort()

print("( "+"\\ \n| ".join(entries)+"\\\n)")
