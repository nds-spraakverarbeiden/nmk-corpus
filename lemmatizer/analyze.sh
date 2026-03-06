#!/bin/bash
HOME_DIR=`dirname $0`;
if echo ' '$*' ' | sed s/'.*'/'\L&'/g | egrep '\s-[-]*h(elp)?\s' >/dev/null; then \
	echo 'When using '`basename $0`', you can only operate with default options and process data from stdin or provided as arguments' 1>&2;\
	echo 'For non-standard configurations, run '$HOME_DIR/fst-wrapper.py 1>&2;\
	echo 1>&2;\
	python3 $HOME_DIR/fst-wrapper.py -h;\
else
	stdbuf -oL cat $* \
	| stdbuf -oL grep -v '^#' \
	| stdbuf -oL python3 $HOME_DIR/fst-wrapper.py $HOME_DIR/parser.conf -c $HOME_DIR/`basename $0`.cache.json -n -t 2 -mmin "[/+-]" 2> >(grep -v 'cyclic analyses' >&2);
fi;

