$V$=[äaeiouöüEIOUÄÖÜåœ] | au | ei | äu | ou % ou tbc
$C$=[bdfghjklmnprstvwxS]
ALPHABET=$V$ $C$ [\-\.A-Za-z\_\=\/]

% basiert auf Mackel (1905, vgl. https://de.wikipedia.org/wiki/Nordm%C3%A4rkisch#Konjugation)

% we use noun classes for GENDER (for sg), resp., NUMBER (pl only)
$CLASS$=Masc|Fem|Neut|Pl

% formally, there is no dative case *in syntax*, but recognizable dative forms are used in fixed expressions 
$CASE$=Nom|Acc|Dat|Gen

$NFEATS$=$CLASS$\.$CASE$

%%%%%%%%%%%%%%%%%%%%%
% dictionary lookup %
%%%%%%%%%%%%%%%%%%%%%
% validation by native (normalized) word lists and word_formation.fst dropped

$NOUN_LEX$= .* / (NOUN|PROPN) [\/A-Za-z\.\_0-9\-]* 

%%%%%%%%%%%%%%%%%%%
% deep morphology %
%%%%%%%%%%%%%%%%%%%
% - segmented norm to morphological features
% - lemmatization candidate, requires confirmation by dictionary lookup
% - includes umlaut (sic!)

$INFLECT_FOR_CASE$=.*{/NOUN\.}:<> \
			( {Masc\.}:<> \
					( {Nom}:<> \
					| {Gen}:{\=s} \
					| {Gen\.arch}:{\=es} \
					| {Dat}:{\='} \
					| {Dat\.arch}:{\=e} \
					| {Acc}:{\=en} \
					) \
			| {Neut\.}:<> \
					( {Nom}:<> \
					| {Gen}:{\=s} \
					| {Gen\.arch}:{\=es} \
					| {Dat}:{\='} \
					| {Acc}:<> \
					) \
			| {Fem\.}:<> \
					( {Nom}:<> \
					% | {Gen}:?? (doesn't exist according to Mackel)\
					| {Dat}:<> \
					| {Acc}:<> \
					) \
			| {Pl}:<> {\.}:<> \
					( {Nom}:<> \
					| {Dat}:{\=en} \
					| {Acc}:<> \
					) \
			)

$UMLAUT$= a:e \
		| å:œ \
		| o:ö \
		| u:ü \
		| O:Ö \
		| U:Ü \
		| {au}:{äu} \
		| {ou}:{äu} \ % if that does exist

$UMLAUT_SAME$=[eiöüÄEIÖÜœ] | ei | äu

% originally, this was applied recursively over the corpus, 
% $INFLECT_FOR_CASE$ yields plural
% Note: multiple plurals limited to forms attested in corpus, cf. $PLURAL$ at validation
$INFER_SG$ = ( ( .* $UMLAUT$ ($C$+ ($UMLAUT$ | $UMLAUT_SAME$))* $C$* /NOUN\.Pl {\_uml}:<> ([\._][a-zA-Z0-9].*)? )	\ % single or multple umlaut, e.g., epelbÖm "Apfelbäume" 
		   	 | ( .* <>:{\='}  / NOUN\.Pl {\_dehn}:<> .* ) 							\ % überlänge oder dehnung, e.g., Smäär < Smett (Mackel) 
		   	 %| ( .*   / NOUN\.Pl {\_0}:<> .* ) 									\ % same as sg, e.g., _ris_, _tE_
		   	 %| ( .*   / NOUN\.Pl .* ) 												\ % words without sg, e.g., _lÜd_
		   	 | ( .* <>:{\=e} /NOUN\.Pl {\_e}:<> .* (\.arch | {\.arch}:<>))			\ % -e plural only in archaic words
		   	 | ( .* <>:{\=er} / NOUN\.Pl {\_er}:<> .* )								\ % -er, e.g., Eier < Ei (Mackel) 
		   	 | ( .* <>:{\=s}  / NOUN\.Pl {\_s}:<> .*  )								\ % -s, e.g., Grääwers (Mackel)
		   	 | ( .* <>:{\=en} / NOUN\.Pl {\_en}:<> .* )								\ % -en, e.g., Håsen (Mackel)
		   	 )

$INFER_GENDER$= .*/NOUN \.:<> ({Masc}:<>|{Neut}:<>|{Fem}:<>) \.Pl .*

% note that INFER_SG can iterate: Worm > Wörmer (uml+-er), Gänt > Gänters (-er+-s), constructed: Hüsers (uml+-er+-s)
$DEEP$=$INFER_GENDER$? || (($INFER_SG$? || $INFER_SG$)? || $INFER_SG$)? || $INFLECT_FOR_CASE$

%%%%%%%%%%%%%%%%%%%%%%
% surface generation %
%%%%%%%%%%%%%%%%%%%%%%
% - Dehnung oder Überlänge
% - morphologische (de)segmentierung

$DEHNUNG$=e:Ä | i:Ä | o:å | a:å | ö:œ 

% wir bilden die form mit und ohne auslautverhärtung, unvollständig
$UEBERLAENGE$	= $C$* f:v 		\ % Mackel: Deiw < Deef
				| $C$* x:[gj] 	\ % Mackel: Dåg < Dach, vgl. Famielch ~ Famielj'
				| $C$* t:d 		\ % 
				| [lrn] [dt]:<> \ % Mackel: Hunn' < Hunt
				| n k:g 		\ % Mackel: Rink < Ring'
				| r [dt]:<> 	\ % Mackel: Peer < Peert

$MND_E$= $DEHNUNG$ $C$* | $DEHNUNG$? $UEBERLAENGE$ 

$SURFACE$= ($V$ | $C$ | {\='}:<> | (<>:e)? {\=er}:r | (<>:e)? {\=en}:n | {\=s}:s | $MND_E$ {\=e}:<> $C$ )* ($MND_E$ ':<>)?

%%%%%%%%%%%%%%%%%%%%%%%%
% validate annotations %
%%%%%%%%%%%%%%%%%%%%%%%%

% note that POS or gender, are normally in $NOUN_LEX$
$GENDER$=Masc|Fem|Neut
$PLURAL$=Pl ( \_0 				\
			| \_uml				\
			| (\_uml)? \_dehn 	\		
			| (\_uml)? \_e 		\	% archaic version of \_dehn
			| (\_uml)? \_en 	\
			| (\_uml)? \_en\_s  \
			| (\_uml)? \_er 	\
			| (\_uml)? \_er\_s  \
			| (\_uml)? \_s 		\
			)?
$CASE$=Nom|Gen|Dat|Acc

% insert lexical features
$INS_FEATS$=( {\.arch}:<> \
			| {\.fam}:<> \
			| {\.frz}:<>\
			| {\.hd}:<> \
			| {\.reg}:<> \
			| {\.ofael}:<>) \
			({\?}:<>)?

$VALIDATE$=\
	$NOUN_LEX$  (\. $PLURAL$)? (\. $CASE$)? || \
	.* / (NOUN|PROPN) ({\?}:<>)? $INS_FEATS$* (\.$GENDER$ ({\?}:<>)?)? $INS_FEATS$* (\. $PLURAL$ ({\?}:<>)?)? $INS_FEATS$* (\. $CASE$)

%%%%%%%%%%%%%%
% norm2lemma %
%%%%%%%%%%%%%%

	$VALIDATE$ ||\
	$DEEP$ || \
	$SURFACE$

