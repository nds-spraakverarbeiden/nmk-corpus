# Release candidate of Fr 16. Aug 14:50:34 CEST 2024

built from  with the following properties:

- model corpus/scripts/models/UD_Dutch-Alpino.lcased.1.model
- evaluation against `corpus/test`
	- accuracy=0.9189473684210526=873/950
	- average precision and recall

		| tag | prec | rec | f | 
		| --- | ---- | --- | - | 
		|ADJ|0.6111111111111112|0.6470588235294118|0.6285714285714287|
		|ADP|0.8421052631578947|0.96|0.8971962616822429|
		|ADV|0.9805825242718447|0.8278688524590164|0.8977777777777779|
		|AUX|1.0|0.9545454545454546|0.9767441860465117|
		|CCONJ|0.9629629629629629|1.0|0.9811320754716981|
		|DET|0.971830985915493|0.9857142857142858|0.9787234042553192|
		|INTJ|1.0|0.5|0.6666666666666666|
		|NOUN|0.8731343283582089|0.9212598425196851|0.896551724137931|
		|NUM|0.0|0|0|
		|PRON|0.9596774193548387|0.9596774193548387|0.9596774193548389|
		|PROPN|0.9166666666666666|0.6875|0.7857142857142857|
		|PUNCT|1.0|0.9881656804733728|0.9940476190476192|
		|SCONJ|1.0|0.6923076923076923|0.8181818181818181|
		|SYM|0|0|0|
		|VERB|0.7947019867549668|0.967741935483871|0.8727272727272727|
		|X|1.0|1.0|1.0|
		|_|0|0|0|

## Build log

	corpus/full/bornemann-1810-gedichte.full.conll > upos/bornemann-1810-gedichte.full.conll
	reading from stdin
	
	corpus/full/bornemann-1813-erz.full.conll > upos/bornemann-1813-erz.full.conll
	reading from stdin
	
	corpus/full/bornemann-1816-gedichte.full.conll > upos/bornemann-1816-gedichte.full.conll
	reading from stdin
	
	corpus/full/bornemann-1868-gedichte.full.conll > upos/bornemann-1868-gedichte.full.conll
	reading from stdin
	
	corpus/full/doerr-1884-goederschlaechter.full.conll > upos/doerr-1884-goederschlaechter.full.conll
	reading from stdin
	
	corpus/full/hill-1868-schnurren.full.conll > upos/hill-1868-schnurren.full.conll
	reading from stdin
	
	corpus/full/jung-1855-gedichte.full.conll > upos/jung-1855-gedichte.full.conll
	reading from stdin
	
	corpus/full/keller-1871.full.conll > upos/keller-1871.full.conll
	reading from stdin
	
	corpus/full/keller-1872.full.conll > upos/keller-1872.full.conll
	reading from stdin
	
	corpus/full/keller-1877.full.conll > upos/keller-1877.full.conll
	reading from stdin
	
	corpus/full/schwerin-1858-altmark.full.conll > upos/schwerin-1858-altmark.full.conll
	reading from stdin
	
	corpus/full/schwerin-1859-voeggel.full.conll > upos/schwerin-1859-voeggel.full.conll
	reading from stdin
	
merged with dictionary-based preannotation, such that 
 - unambiguous preannotation overrides HMM annotation
 - for ambiguous preannotations compatible with HMM output, use HMM output
 - for ambiguous preannotations not compatible with HMM output, use HMM output and mark tag by ?
 - if no automated pre-annotation, use HMM output

columns:
- **WORD**
- **MERGED**
- **HMM**
- **DICT**
