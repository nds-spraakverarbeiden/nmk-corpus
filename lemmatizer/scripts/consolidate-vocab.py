import re,os,sys,json,io,traceback
from pprint import pprint

""" read JSON and JSONL from args or stdin, but merge duplicate keys rather than overwriting them """

# # default is overwriting as in the following 
# input='{"this": ["is"], "this":["a","test"]}'
# print(input)
# input=json.load(io.StringIO(input))
# print(input)

def sort(data):
	""" sort recursively, both lists and dicts, eliminate duplicates, can be applied to the output of merge """
	if data==None or len(data)==0: return data

	if isinstance(data,list):
		return [ sort(x) for x in sorted(set(data)) ]

	if isinstance(data,dict): 
		result={}
		for k in sorted(data):
			result[k]=sort(data[k])
#		data_str=str(data)
#		result_str=str(result)
#		if(data_str!=result_str):
#			print("UNSORTED",data)
#			print("SORTED",result)
#			print()

		return result

	if isinstance(data,str):
		return data

	print(f"unsupported datatype {type(data)}")
	return data

def merge(data1,data2,sorted=False): 
	""" we expect parallel data structures, e.g., one dict and another dict, on all levels,
		then, we aggregate
		note that we do skip repeated elements for lists
		"""
	result=None
	if data1==data2: 
		result=data1
	elif data1==None: 
		result=data2
	elif data2==None: 
		result= data1
	elif len(data1)==None:
		result= data2
	elif len(data2)==None: 
		result= data1
	elif isinstance(data1,dict) and isinstance(data2,dict):
		for k,v in data2.items():
			if not k in data1:
				data1[k]=v
			else:
				data1[k]=merge(data1[k],v)
		result=data1
	elif isinstance(data1,list) and isinstance(data2,list):
		for v in data2:
			if not v in data1:
				data1.append(v)
		result= data1
	elif isinstance(data1,list):
		result= merge(data1,[data2])
	elif isinstance(data2,list):
		result= merge([data1],data2)
	else:
		result = [data1,data2]

	if sorted:
		result=sort(result)

	return result

def _convert(raw): 
	""" convert nested lists with types '<list>' or '<dict>' to Python lists and dicts, recursively """
	if isinstance(raw,str):
		return raw.strip('"')
	if len(raw)==0:
		return raw
	if len(raw)>0:
		if raw[0]=="<list>":
			result=[]
			if len(raw)>1:
				if isinstance(raw[1],list):
					if len(raw[1])>1 and raw[1][1] in ["<list>","<dict>"]:
						result=[ _convert(raw[1])]
					else:
						result=[ _convert(e) for e in raw[1] if not e.strip()==","]
				else:
					result=[_convert(raw[1])]
			return result
		if raw[0]=="<dict>":
			result={}
			if len(raw[1])>0:
				n=0
				while(n<len(raw[1])):
					#print("RAW[1]:",raw[1])
					#print(f"RAW[1][{n}]:",raw[1][n])
					#print(f"RAW[1][{n+2}]:",raw[1][n+2])

					try:
						k=_convert(raw[1][n])
						#print("k:",k)
						n+=2 # skip ':'
						v=_convert(raw[1][n])
						n+=2 # skip ','
						#print(f"k: {k}, v: {v}")
						mydict={k:v}
						result=merge(result,mydict)
					except Exception:
						traceback.print_exc()
			return result

	raise Exception("error: invalid input")

def read(stream, sorted=True): 
	# induce raw data structures and return as JSON string

	raw=_read(stream)

	# convert to Python lists, dicts and strings
	result=_convert(raw)

	if sorted:
		result=sort(result)

	return result

def _read(stream): 
	""" parse JSON or JSONL with duplicate keys, return nested lists whose first entry designates the type as '<list>' or '<dict>' """ 

#	sys.stderr.write(f"read({stream})\n")
#	sys.stderr.flush()


# TODO: support escape keys:
#    \"
#     \\
#     \/
#     \b
#     \f
#     \n
#     \r
#     \t
#     \u followed by four-hex-digits

	results=[]
	line=0

	try:
		# convert text streams to strings
		stream="".join(stream.readlines())
	except Exception:
		pass

	# ignore escape characters for now
	n=0
	string=""
	while(n<len(stream)):
		c=stream[n]
		n+=1
		if c=="\n":
			line+=1

		string=c
#		print(string,c)
		c=c.strip()
		if c=='[':
			opened=1
			while(n<len(stream)):
				c=stream[n]
				n+=1
				string+=c
				if c=="]": opened-=1
				if c=="[": opened+=1
				if opened==0:
					break					
			results.append(["<list>",_read(string.strip()[1:].rstrip("]"))])
			string=""
		elif c=="{": 
			opened=1
			while(n<len(stream)):
				c=stream[n]
				n+=1
				string+=c
				if c=="}": opened-=1
				if c=="{": opened+=1
				if opened==0:
					break					
			results.append(["<dict>",_read(string.strip()[1:].rstrip("}"))])
			string=""
		elif c=='"':
			while(n<len(stream)):
				c=stream[n]
				n+=1
				string+=c
				if c=='"':
					break
			results.append(string)
			#sys.stderr.write(f"C/N: {c},{n}, {string}, {results}\n")
			string=""
		elif c in [":",","]:
			results.append(c)
			string=""
		elif c=="":
			continue
		else:
			raise Exception(f"invalid symbol {c} in line {line+1} at\n"+stream[:n].split("\n")[-1]+f">>>{c}<<<"+stream[n+1:].split("\n")[0])

	if string.strip()!="":
		raise Exception(f"invalid symbol {c} in line {line+1} at\n"+stream[:n].split("\n")[-1]+f">>>{c}<<<")

	if len(results)==1:
		return results[0] 	# for JSON
	return results 			# for JSONL

#read('["this","is","a","test"]')
#sys.exit()

files=sys.argv[1:]
if len(files)==0:
	files=[sys.stdin]
	sys.stderr.write("reading from stdin\n")

data=None
for file in files: 
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		file=open(file,"rt",errors="ignore")
	sys.stderr.flush()
	last_c=" "
	my_data=read(file)
	if data==None:
		data=my_data
	else:
		data=merge(data,my_data,sort=True)

	try:
		file.close()
	except Exception:
		pass

json.dump(data,sys.stdout)
