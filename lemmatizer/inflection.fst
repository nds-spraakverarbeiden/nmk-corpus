% implements lemmatization and inflection, based on `../morph/lemmatize.fst`
% limited by controlled vocabulary lists

%%%%%%%%%%%%%%%%%%%%%
% phoneme inventory %
%%%%%%%%%%%%%%%%%%%%%

% consonants
$C$=[bdfghjklmnprstvwxS]
$SEP$=['\-]
$V$=[äaeiouöüAEIOUÖÄÜåœ] | au | ei | äu \
	| ou 		% to be confirmed \
	| ä:e ä:a  	% original a or e differently realized as either a or e, \
				% e.g., _det_ (N.Mk.) "das" vs. _dat_ (C.Pm.) or _enner_ \
				% "ander(er)" (N.Mk) vs. _anner_ (C.Pm.), but note that \
				% these are very different regional processes 

ALPHABET= $C$ $V$ $SEP$ [\ ] 
%%%%%%%%%%%%%%%%%%%%%
% (inflected) words %
%%%%%%%%%%%%%%%%%%%%%
% lemma matching requires clitic delimination and consonant simplification

% placeholders
$PROCLITIC$=\
	{dät\ }:{t'} | \ % mpomm: dat
	{de\ }:{t'} |\ % dE?
	{ik\ }:{k'} |\
	{En\ }:{n'} |\
	{Enen\ }:{n'} |\
	{de\ }:{d'} |\
	{dät\ }:{d'} % mpomm: dat

$ENCLITIC$=\
	{\ dät}:{'t} |\ % mpomm: dat
	{\ de}:{'t} |\ % dE?
	{\ ik}:{'k} |\
	{\ se}:{'s} |\ % sE?
	{\ wI}:{'f} | \
	{\ jI}:{'x} |\
	{\ jU}:{'x} |\
	{\ jI}:{'j} |\
	{\ jU}:{'j} |\
	{\ dät}:{'d} | \ % mpomm dat
	{\ de}:{'d} | % dE? \
	{\ En}:{'n} | \
	{\ Enen}:{'n} | \
	{\ danen}:{'n} | \ % mpomm, prüfe form in den texten
	{\ is}:{'s}  % copula!

%%%%%%%%%%%%%%
% norm2lemma %
%%%%%%%%%%%%%%
% optionally, the norm may contain ' to mark either cliticization, syllable boundaries or apocopy/syncopy

#include "desyllabify.fst"

ALPHABET=[a-zA-ZöäüÖÄÜß0-9'\-/\.\ ()]

$PARSE_WORD$= "<verbs.a>" 	\
			| "<nouns.a>" 	\
			| "<adj.a>" 	\
			| "<pron.a>"	\ 
			| "<prep.a>"	\
			| "<conj.a>"	\
			| "<part.a>"	\
			| "<closed.a>" 	\
%			| "<vocab.a>"   \
%			| "<danneil.a>" {.altmk}:<> \
			% | "<danneil.a>" \ % without the .altmk flag, it should be more compact
			
$ANALYZE$=$PARSE_WORD$ ([\ ] $PARSE_WORD$)*

% split word from clitics and desyllabify word \
$ANALYZE$ ||\
$PROCLITIC$* $DESYLLABIFY$ $ENCLITIC$* ( [\ ] $PROCLITIC$* $DESYLLABIFY$ $ENCLITIC$*)*

