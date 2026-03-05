SHELL=bash

all: norm norm_dict.a inflection.a dicts.a infl_dict.a word_formation

roots.dic: dict/danneil.json dict/vocab_full.json
	 ( cat dict/vocab_full.json |  jq "keys|.[]" ; \
			  cat dict/danneil.json | jq "keys|.[]"; \
			  cat adj.dic intj.dic nouns.dic  num.dic  punct.dic  sym.dic  verbs.dic;\
			  #| sed s/'"$$'/'.altmk"'/;\
			) \
			| sed s/'"'//g \
			| sed s/'.*[+]\([^\+]*\/\(NOUN\|VERB\|ADJ\)\)'/'\1'/ \
			| sed s/'.*\-'//g \
			| sed s/'[+]'//g \
			| sed   -e s/í/i/g \
							-e s/é/e/g \
							-e s/á/a/g \
							-e s/ó/o/g \
							-e s/ú/u/g \
			| grep -v '\.\.' \
			| egrep -v '[!*?]' \
			| sort -u > roots.dic

lexemes.dic: dict/danneil.json dict/vocab_full.json
		( cat dict/vocab_full.json |  jq "keys|.[]" ; \
		  cat dict/danneil.json | jq "keys|.[]" ; \
		  cat adj.dic intj.dic nouns.dic  num.dic  punct.dic  sym.dic  verbs.dic;\
		) \
		| grep '[\+\-]' \
		| sed s/'"'//g \
		| sed s/'DO NOT REPLACE[+\?\-]'//g \
		| sed   -e s/í/i/g \
						-e s/é/e/g \
						-e s/á/a/g \
						-e s/ó/o/g \
						-e s/ú/u/g \
		| egrep -v '[?!*]' \
		| grep -v '\.\.' \
		> lexemes.dic

# build transducers from dict/*
dicts.a: dict/danneil.json dict/vocab_full.json roots.dic lexemes.dic
	cats='prep part';\
	for cat in $$cats; do \
		if [ ! -e $$cat.fst ]; then \
			if [ ! -e dicts/$$cat.json ]; then \
				if [ ! -e dicts/$$cat.tsv ]; then \
					echo -n did not find prep.tsv 1>&2;\
					if [ -e dicts/$$cat.xlsx ]; then \
						echo -n ' 'please export from dicts/$$cat.xslx 1>&2; \
					fi;\
					echo 1>&2;\
					exit 1; \
				fi;\
				python3 tsvdict2json.py dict/$$cat.tsv -l 0 -n 1 -f 2 -p 3 -pf 6 \
				| jq . \
				> dict/$$cat.json;\
			fi;\
			python3 json2fst.py dict/$$cat.json > $$cat.fst;\
		fi;\
		fst-compiler-utf8 $$cat.fst $$cat.a;\
	done;\

	cats='conj';\
	for cat in $$cats; do \
		if [ ! -e $$cat.fst ]; then \
			if [ ! -e dicts/$$cat.json ]; then \
				if [ ! -e dicts/$$cat.tsv ]; then \
					echo -n did not find prep.tsv 1>&2;\
					if [ -e dicts/$$cat.xlsx ]; then \
						echo -n ' 'please export from dicts/$$cat.xslx 1>&2; \
					fi;\
					echo 1>&2;\
					exit 1; \
				fi;\
				python3 tsvdict2json.py dict/$$cat.tsv -l 0 -n 1 -f 2 -p 3 -pf 4 \
				| jq . \
				> dict/$$cat.json;\
			fi;\
			python3 json2fst.py dict/$$cat.json > $$cat.fst;\
		fi;\
		fst-compiler-utf8 $$cat.fst $$cat.a;\
	done;\

	@cats='danneil vocab_full vocab';\
	for cat in $$cats; do \
		if [ ! -e $$cat.a ]; then \
			if [ ! -e $$cat.fst ]; then \
				echo dict/$$cat.json '>' $$cat.fst 1>&2;\
				python3 json2fst.py dict/$$cat.json \
				| sed -e s/'[!&*]'/'\\&'/g \
			  		  -e s/'\({\)\([:]\)'/'\1\\\2'/g \
			  		  -e s/'\.ocr'//g \
			  		  -e s/'\?'//g\
				> $$cat.fst;\
			fi;\
			echo $$cat.fst '>' $$cat.a 1>&2;\
			fst-compiler-utf8 $$cat.fst $$cat.a;\
		fi;\
	done;

	fst-compiler-utf8 dicts.fst dicts.a

syllab.a:
	fst-compiler-utf8 syllab.fst syllab.a

update_norm:
	@for file in *2norm.a; do \
		if [ -e $$file ]; then \
			rm $$file;\
		fi;\
	done;\
	make norm

norm: syllab.a
	for file in *2norm.fst; do \
		if [ -e $$file ]; then \
			tgt=`echo $$file | sed s/'\.fst$$'//`.a;\
			if [ ! -e $$tgt ]; then \
				echo $$file '>' $$tgt 1>&2;\
				fst-compiler-utf8 $$file $$tgt;\
				echo 1>&2;\
			fi;\
		fi;\
	done

norm_dict.a:  ../dict/vocab_full.json ../dict/vocab.json
	for param in "" "_full"; do \
		dict=../dict/vocab$$param.json;\
		fst=norm_dict$$param.fst;\
		a=norm_dict$$param.a;\
		if [ -e $$dict ]; then \
			if [ ! -e $$fst ]; then \
				python3 json2fst.py $$dict -syll \
				| sed -e s/'\([!._*?&;]\)'/'\\\1'/g \
					  -e s/'\([^}>\]\):\([^{<\[]\)'/'\1\\:\2'/g \
					  -e s/'\\\\'/'\\'/g \
				> $$fst;\
			fi;\
			fst-compiler-utf8 $$fst $$a;\
		fi;\
	done

participles.fst: dict/vocab_full.json
	(echo -n '$$PARTICIPLE$$ = ';\
	(jq -r 'paths(scalars | true) as $$p  | [ ( [ $$p[] | tostring ] | join("\t") ), ( getpath($$p) | tojson )] | join(": ")' dict/vocab_full.json; \
	 jq -r 'paths(scalars | true) as $$p  | [ ( [ $$p[] | tostring ] | join("\t") ), ( getpath($$p) | tojson )] | join(": ")' dict/danneil.json ) \
	| grep PPast \
	| cut -f 1,2,3 | cut -f 1,3 -d "/" | grep -v ' ' \
	| sed s/'?\|\.ocr'//g \
	| uniq | sort -u \
	| sed s/'[_\.\+\-]'/'\\&'/g \
	| sed s/'\(.*\)\t\(.*\)'/' | {\1}:{\2} '/g \
	| perl -pe 's/\s+/ /g;' \
	| perl -pe 's/\s+/ /g; s/^[\s|]*//; s/\|/\\\n\t|/g;'; \
	echo ) \
	> participles.fst
	
	# for debugging
	# fst-compiler-utf8 participles.fst participles.a

inflection.a:
	levels="verbs nouns adj pron prep conj part closed inflection";\
	for level in $$levels; do \
		if [ ! -e $$level.a ]; then \
			fst-compiler-utf8 $$level.fst $$level.a;\
		fi;\
	done;

infl_dict.a: inflection.a dicts.a
	fst-compiler-utf8 infl_dict.fst infl_dict.a

# emulate lemmatizer v.0.2 performance by not using vocab_full, but only vocab
infl_dict.v.0.2.a:
	fst-compiler-utf8 dicts.v.0.2.fst dicts.v.0.2.a
	fst-compiler-utf8 infl_dict.v.0.2.fst infl_dict.v.0.2.a
	
update_word_formation:
	for file in word_formation_*.a roots.dic lexemes.dic participles.fst; do if [ -e $$file ]; then rm $$file; fi; done
	make word_formation

word_formation: participles.fst word_formation.fst roots.dic lexemes.dic  
	@for nr in {0..10}; do \
		src=word_formation_$$nr.fst;\
		tgt=word_formation_$$nr.a;\
		if [ -e $$src ]; then \
			if [ ! -e $$tgt ] ; then \
				echo $$src '>' $$tgt 1>&2;\
				fst-compiler-utf8 $$src $$tgt;\
			else \
				if [ $$src -nt $$tgt ]; then \
					echo $$src '>' $$tgt 1>&2;\
					fst-compiler-utf8 $$src $$tgt;\
				else \
					echo found $$tgt, to update it, run make update_word_formation or delete manually 1>&2;\
				fi;\
			fi;\
		fi;\
	done;

test: word_formation	
	@if [ -e analyze.sh.cache.json ]; then echo "warning: using analyze.sh.cache.json, you might want to clear that beforehand" 1>&2; fi;\
	 bash -e ./analyze.sh test.txt

################################
# possible addenda from v.0.02 #
################################
# to be reactivated on demand
# 
# 
# ##################
# # dict expansion #
# ##################
# # we don't create dict from scratch, because its content is manually curated
# # but we infer probability-weighted unattested analyses for attested forms, using full_forms/*curated.tsv as basis
# 	
# expand_dict: dict/danneil.json dict/vocab.json
# 	jdicts=`find dict | grep 'json$$' | grep -v 'expanded.json'`;\
# 	echo $$jdicts;\
# 	sources=$$( \
# 			(cat dict/vocab.json \
# 				| jq ".[][][][]|values[]";\
# 			cat dict/danneil.json \
# 				| jq ".[][][][]|keys[]"; \
# 			) \
# 			| grep '"' \
# 			| sort -u \
# 			| cut -f 2 -d '"' \
# 			| sed s/'.*\/'//g \
# 			| cut -f 1 -d '.' \
# 			| sort -u;\
# 		);\
# 	\
# 	echo $$sources;\
# 	for s in $$sources; do \
# 		tgt=dict/$$s.expanded.json;\
# 		echo $$jdicts '>' $$tgt 1>&2;\
# 		(python3 dict2full_forms.py $$jdicts -tsv full_forms/*.curated.tsv -j -s $$s \
# 		 > $$tgt) \
# 		>& $$tgt.log;\
# 	done;\
# 	for s in $$sources; do \
# 		curated=full_forms/$$s.*curated.tsv;\
# 		if [ ! -e $$curated ]; then \
# 			tgt=full_forms/$$s.from_dict.tsv;\
# 			echo $$jdicts '>' $$tgt 1>&2;\
# 			(python3 dict2full_forms.py $$jdicts -tsv full_forms/*.curated.tsv -s $$s \
# 			 > $$tgt) \
# 			>& $$tgt.log;\
# 		fi;\
# 	done;
# 
# 
# ##############
# # full_forms #
# ##############
# # instead of building an end2end lemmatizer, we bootstrap full_form lists
# 
# full_forms: update_full_forms
# 
# update_full_forms: 
# 	@if [ ! -e full_forms ]; then mkdir full_forms; fi;
# 
# 	@# "short" / "short name" is the element before 2norm in *.fst
# 
# 	@conll2short="../corpus/full/keller-1871.full.conll:keller ../corpus/full/keller-1872.full.conll:keller ../corpus/full/keller-1877.full.conll:keller   ../corpus/full/jung-1855-gedichte.full.conll:jung ../corpus/full/bornemann-1868-gedichte.full.conll:born186x ../corpus/full/bornemann-1810-gedichte.full.conll:born181x ../corpus/full/bornemann-1816-gedichte.full.conll:born181x ../corpus/full/doerr-1884-goederschlaechter.full.conll:doerr ../corpus/full/hill-1868-schnurren.full.conll:hill"; \
# 	\
# 	for c2s in $$conll2short; do \
# 		file=`echo $$c2s | sed s/':.*'//`;\
# 		short_name=`echo $$c2s | sed s/'.*:'//`;\
# 		vocab_filter=`echo $$short_name | sed -e s/'^\(.*[0-9]\)[^0-9].*'/'\1'/ -e s/'[0-9]'/'.*&'/ -e s/'^.*$$'/'.*&[^\/]*'/`;\
# 		tgt=full_forms/`basename $$file | sed s/'\.conll[u]*$$'//`.raw.tsv;\
# 		curated=full_forms/`basename $$file | sed s/'\.conll[u]*$$'//`.curated.tsv;\
# 		in_progress=full_forms/`basename $$file | sed s/'\.conll[u]*$$'//`.in-progress.tsv;\
# 		curated_short=full_forms/$$short_name.full.curated.tsv;\
# 		in_progress_short=full_forms/$$short_name.full.in-progress.tsv;\
# 		\
# 		fst=$${short_name}2norm.fst;\
# 		if [ -e $$curated ]; then \
# 			echo warning: found $$curated, skipping $$c2s 1>&2;\
# 		else if [ -e $$in_progress ] ; then \
# 			echo warning: found $$in_progress, skipping $$c2s 1>&2;\
# 		else if [ -e $$curated_short ]; then \
# 			echo warning: found $$curated_short, skipping $$c2s 1>&2;\
# 		else if [ -e $$in_progress_short ]]; then \
# 			echo warning: found $$in_progress_short, skipping $$c2s 1>&2;\
# 		else \
# 			a=`echo $$fst | sed s/'\.fst$$'//`.a;\
# 			if [ ! -e $$a ]; then make $$a; fi;\
# 			\
# 			if [ -e $$tgt ]; then \
# 				echo warning: found $$tgt, skipping $$c2s 1>&2; \
# 			else \
# 				if [ ! -e $$file ]; then \
# 					echo error: did not find $$file, skipping $$c2s 1>&2; \
# 				else \
# 					make inflection.a expand_dict;\
# 					words=full_forms/$$short_name.words.tmp;\
# 					morph=full_forms/$$short_name.morph.tmp;\
# 					echo -n $$file '>' $$words '+' $$morph ' ' 1>&2;\
# 					\
# 					cat $$file \
# 					| cut -f 1 \
# 					| grep -v '#' \
# 					| egrep . \
# 					| sort -u \
# 					| tee $$words \
# 					| sed s/'$$'/'\n'/g \
# 					| fst-parse -t inflection.a $$a \
# 					| sed s/'no analysis for ""'// \
# 					| sed s/'no analysis for ".*'/'_'/ \
# 					| sed s/'"'/"''"/g \
# 					| sed s/'..*'/'"&"'/g \
# 					| perl -pe 's/"\s+/",/g' \
# 					| sed s/',*$$'// \
# 					> $$morph;\
# 					\
# 					echo '>' $$tgt '-d' dict/vocab.json':'$$vocab_filter 1>&2;\
# 					paste $$words $$morph \
# 					| (python3 consolidate-full-forms.py -d dict/vocab.json:$$vocab_filter -t2n $${short_name}2norm.a -n2a inflection.a -resyl) 2>$$tgt.log  \
# 					> $$tgt;\
# 				fi;\
# 			fi;\
# 		fi; fi; fi; fi;\
# 	done;
# 
# 	@rm full_forms/*.tmp >&/dev/null || echo >/dev/null 
