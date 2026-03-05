$V$=[äaeiouöüÄÖÜEIOUœå] | ei | au | äu | ou % ou tbc.
$C$=[bdfghjklmnprstvwxS]
ALPHABET=$V$ $C$ ['\-\.A-Za-z0-9\=\/]

% interrogativepronomen not yet
% inflection of possessive pronouns yet to be added

% basiert auf Mackel: https://de.wikipedia.org/wiki/Nordm%C3%A4rkisch#Personal-_und_Possessivpronomen

% _et_ is regionally and over time replaced by _det_ (_dat_)
% vgl. et:det/dat/dät
% Bornemann 1810: 	43.2%	35:46 
% Bornemann 1816: 	34.5%	41:78
% Bornemann 1868: 	27.5% 	165:436
% Jung 1855: 		43.3%	237:310
% Dörr 1884: 		13.6%	179:1140
% Hill 1868:		0 		0:266
% According to Mackel, _et_ didn't exist in Prignitz around 1900

% det/dat is spelled dät, here, to indicate that e alternates with a

$DEEP$= \
	{PRON\.}:<> \
			( {1\.}:<> \
				({Nom\.Sg}:{ik} \
				|{Dat\.Sg}:{mI} \
				|{Acc\.Sg}:{mI} \
				|{Nom\.Pl}:{wI} \
				|{Dat\.Pl}:{uns} \
				|{Acc\.Pl}:{uns} \
				|( {Poss\.Sg}:{mIn} .*) \
				|( {Poss\.Pl}:{uns\='} .* ) \
				|( {Poss\.Pl\.hd}:{uns\=er} .* ) \	% Hill: wat föar uns're Schnuut
				|{Nom\.Sg\.clit}:{k} \
				|{Nom\.Pl\.clit}:[wf] \
				) \
			| {2\.}:<> \
				({Nom\.Sg}:{dU} \
				|{Dat\.Sg}:{dI} \
				|{Acc\.Sg}:{dI} \
				|{Nom\.Pl}:{jI} \
				|{Dat\.Pl}:{jU} \
				|{Acc\.Pl}:{jU} \
				|{Dat\.Pl}:{jUx} \ % attested in Kr. Greifenhagen
				|{Acc\.Pl}:{jUx} \ % attested in Kr. Greifenhagen
				| ( {Poss\.Sg}:{dIn} .*) \
				| ( {Poss\.Pl}:{jU} .*) \
				| ( {Poss\.Pl}:{jU} .* ) \
				| ( {Poss\.Pl}:{jUn} .*) \	% Mackel gives jU only, but the texts also have jUn
				|{Nom\.Sg\.clit}:[dt] \
				|{Dat\.Sg\.clit}:[dt] \
				|{Acc\.Sg\.clit}:[dt] \
				|{Nom\.Pl\.clit}:[jx] \
				|{Dat\.Pl\.clit}:[jx] \
				|{Acc\.Pl\.clit}:[jx] \
				) \
			| {3\.}:<> \
				({Nom\.Sg\.Masc}:{hE} \
				|{Dat\.Sg\.Masc}:{em} \
				|{Acc\.Sg\.Masc}:{em} \
				|{Nom\.Sg\.Fem}:{sE} \
				|{Dat\.Sg\.Fem}:{Er} \
				|{Acc\.Sg\.Fem}:{sE} \
				|{Acc\.Sg\.Fem}:{Er} \
				|{Nom\.Sg\.Neut}:{et} \		% we deviate from Mackel because the older texts still use et, det/dat is Dem
				|{Dat\.Sg\.Neut}:{et} \
				|{Acc\.Sg\.Neut}:{et} \
				|{Nom\.Pl}:{sE} \
				|{Dat\.Pl}:{sE} \
				|{Dat\.Pl}:{Er} \
				|{Acc\.Pl}:{sE} \
				| ( {Poss\.Sg\.Masc}:{sIn} .*) \
				| ( {Poss\.Sg\.Fem}:{Er} .*) \
				| ( {Poss\.Sg\.Neut}:{sIn} .*) \
				| ( {Poss\.Pl}:{Er} .*) \
				|{Nom\.Sg\.Masc\.clit}:{er} \
				|{Dat\.Sg\.Masc\.clit}:{m} \
				|{Acc\.Sg\.Masc\.clit}:{m} \
				|{Nom\.Sg\.Fem\.clit}:{s} \
				|{Acc\.Sg\.Fem\.clit}:{s} \
				|{Nom\.Sg\.Neut\.clit}:{t} \	% these also apply to demonstrative (neuter) pronouns
				|{Dat\.Sg\.Neut\.clit}:{t} \
				|{Acc\.Sg\.Neut\.clit}:{t} \
				|{Nom\.Pl\.clit}:{s} \
				|{Dat\.Pl\.clit}:{s} \
				|{Acc\.Pl\.clit}:{s} \
				) \
			| {Dem\.}:<> \						% short demonstrative pronouns, forms correspond to definite article
				({Nom\.Sg\.Masc}:{dE} \
				|{Dat\.Sg\.Masc}:{den\=en} \ 		% Mackel gives a form with syllabic -en and this is often also written
				|{Acc\.Sg\.Masc}:{den\=en} \		% but not always !
				|{Nom\.Sg\.Fem}:{dE} \
				|{Dat\.Sg\.Fem}:{dE} \
				|{Acc\.Sg\.Fem}:{dE} \
				|{Nom\.Sg\.Neut\.mk}:{det} \		% we deviate from Mackel because the older texts still use et, we annotate det/dat as Dem
				|{Dat\.Sg\.Neut\.mk}:{det} \		% for the neuter, these have replaced the pronouns
				|{Acc\.Sg\.Neut\.mk}:{det} \
				|{Nom\.Sg\.Neut\.mp}:{dat} \	% Central Pomeranian
				|{Dat\.Sg\.Neut\.mp}:{dat} \
				|{Acc\.Sg\.Neut\.mp}:{dat} \	% for clitics see personal pronouns, also used in Central Pomeranian
				|{Nom\.Sg\.Neut}:{dät} \	% general form
				|{Dat\.Sg\.Neut}:{dät} \
				|{Acc\.Sg\.Neut}:{dät} \
				|{Nom\.Pl}:{dE} \
				|{Dat\.Pl}:{dE} \
				|{Acc\.Pl}:{dE} \
				) \
			| {Dem2\.}:<> \						% long demonstrative pronouns, vowel /ü/ according to Mackel, Bornemann and Jung
				({Nom\.Sg\.Masc}:{düs} \
				|{Dat\.Sg\.Masc}:{düs\=en} \ 		
				|{Acc\.Sg\.Masc}:{düs\=en} \		
				|{Nom\.Sg\.Fem}:{düs} \
				|{Dat\.Sg\.Fem}:{düs} \
				|{Acc\.Sg\.Fem}:{düs} \
				|{Nom\.Sg\.Fem\.arch}:{düs\=e} \
				|{Dat\.Sg\.Fem\.arch}:{düs\=e} \
				|{Acc\.Sg\.Fem\.arch}:{düs\=e} \
				|{Nom\.Sg\.Neut}:{düt} \		
				|{Dat\.Sg\.Neut}:{düt} \		
				|{Acc\.Sg\.Neut}:{düt} \
				|{Nom\.Pl}:{düs} \
				|{Dat\.Pl}:{düs} \
				|{Acc\.Pl}:{düs} \
				|{Nom\.Sg\.Masc}:{dis} \		% Dörr and Hill write _i_, not _ü_, otherwise, we give Mackel's forms
				|{Dat\.Sg\.Masc}:{dis\=en} \ 		
				|{Acc\.Sg\.Masc}:{dis\=en} \		
				|{Nom\.Sg\.Fem}:{dis} \
				|{Dat\.Sg\.Fem}:{dis} \
				|{Acc\.Sg\.Fem}:{dis} \
				|{Nom\.Sg\.Fem\.arch}:{dise} \
				|{Dat\.Sg\.Fem\.arch}:{dise} \
				|{Acc\.Sg\.Fem\.arch}:{dise} \
				|{Nom\.Sg\.Neut}:{dit} \		
				|{Dat\.Sg\.Neut}:{dit} \		
				|{Acc\.Sg\.Neut}:{dit} \
				|{Nom\.Pl}:{dis} \
				|{Dat\.Pl}:{dis} \
				|{Acc\.Pl}:{dis} \
				) \
			| {Refl\.Acc}:{sik} % pl=sg \
			) \
	\
	| {DET\.}:<> \
		( {Def\.}:<> \						% definite article
				({Nom\.Sg\.Masc}:{dE} \
				|{Dat\.Sg\.Masc}:{denen} \
				|{Acc\.Sg\.Masc}:{denen} \
				|{Nom\.Sg\.Fem}:{dE} \
				|{Dat\.Sg\.Fem}:{dE} \
				|{Acc\.Sg\.Fem}:{dE} \
				|{Nom\.Sg\.Neut\.mk}:{det} \		% we deviate from Mackel because the older texts still use et, we annotate det/dat as Dem
				|{Dat\.Sg\.Neut\.mk}:{det} \		% for the neuter, these have replaced the pronouns
				|{Acc\.Sg\.Neut\.mk}:{det} \
				|{Nom\.Sg\.Neut\.mp}:{dat} \	% Central Pomeranian
				|{Dat\.Sg\.Neut\.mp}:{dat} \
				|{Acc\.Sg\.Neut\.mp}:{dat} \	% for clitics see personal pronouns, also used in Central Pomeranian
				|{Nom\.Sg\.Neut}:{dät} \	% general form
				|{Dat\.Sg\.Neut}:{dät} \
				|{Acc\.Sg\.Neut}:{dät} \
				|{Nom\.Pl}:{dE} \
				|{Dat\.Pl}:{dE} \
				|{Acc\.Pl}:{dE} \
				) \
		| {Ind\.}:<> \					% indefinite article. note that Mackel gives the clitic forms only
				({Nom\.Sg\.Masc}:{En} \
				|{Dat\.Sg\.Masc}:{Enen} \
				|{Acc\.Sg\.Masc}:{Enen} \
				|{Nom\.Sg\.Fem}:{En} \
				|{Dat\.Sg\.Fem}:{En} \
				|{Acc\.Sg\.Fem}:{En} \
				|{Nom\.Sg\.Neut}:{En} \		
				|{Dat\.Sg\.Neut}:{En} \		
				|{Acc\.Sg\.Neut}:{En} \
				|{Nom\.Sg\.Masc\.clit}:{n} \
				|{Dat\.Sg\.Masc\.clit}:{n} \
				|{Acc\.Sg\.Masc\.clit}:{n} \
				|{Nom\.Sg\.Fem\.clit}:{n} \
				|{Dat\.Sg\.Fem\.clit}:{n} \
				|{Acc\.Sg\.Fem\.clit}:{n} \
				|{Nom\.Sg\.Neut\.clit}:{n} \		
				|{Dat\.Sg\.Neut\.clit}:{n} \		
				|{Acc\.Sg\.Neut\.clit}:{n} \
				)\
		| {Dem\.}:<> \						% = long demonstrative pronouns, Mackel, Bornemann and Jung write _ü_, Dörr and Hill write _i_
				({Nom\.Sg\.Masc}:{düs} \
				|{Dat\.Sg\.Masc}:{düsen} \ 		
				|{Acc\.Sg\.Masc}:{düsen} \		
				|{Nom\.Sg\.Fem}:{düs} \
				|{Dat\.Sg\.Fem}:{düs} \
				|{Acc\.Sg\.Fem}:{düs} \
				|{Nom\.Sg\.Fem\.arch}:{düse} \
				|{Dat\.Sg\.Fem\.arch}:{düse} \
				|{Acc\.Sg\.Fem\.arch}:{düse} \
				|{Nom\.Sg\.Neut}:{düt} \		
				|{Dat\.Sg\.Neut}:{düt} \		
				|{Acc\.Sg\.Neut}:{düt} \
				|{Nom\.Pl}:{düs} \
				|{Dat\.Pl}:{düs} \
				|{Acc\.Pl}:{düs} \
				|{Nom\.Sg\.Masc}:{dis} \		% Dörr and Hill write _i_, not _ü_, otherwise, we give Mackel's forms
				|{Dat\.Sg\.Masc}:{disen} \ 		
				|{Acc\.Sg\.Masc}:{disen} \		
				|{Nom\.Sg\.Fem}:{dis} \
				|{Dat\.Sg\.Fem}:{dis} \
				|{Acc\.Sg\.Fem}:{dis} \
				|{Nom\.Sg\.Fem\.arch}:{dise} \
				|{Dat\.Sg\.Fem\.arch}:{dise} \
				|{Acc\.Sg\.Fem\.arch}:{dise} \
				|{Nom\.Sg\.Neut}:{dit} \		
				|{Dat\.Sg\.Neut}:{dit} \		
				|{Acc\.Sg\.Neut}:{dit} \
				|{Nom\.Pl}:{dis} \
				|{Dat\.Pl}:{dis} \
				|{Acc\.Pl}:{dis} \
				) \
		)

% surface generation 
% taken from adjectives

% Dehnung und Überlänge von Nomen
$DEHNUNG$=e:Ä | i:Ä | o:å | a:å | ö:œ

% wir bilden die form mit und ohne auslautverhärtung, unvollständig
$UEBERLAENGE$	= $C$* f:v 		\ % Mackel: Deiw < Deef
				| $C$* x:[gj] 	\ % Mackel: Dåg < Dach, vgl. Famielch ~ Famielj'
				| $C$* t:d 		\ % 
				| [lrn] [dt]:<> \ % Mackel: Hunn' < Hunt
				| n k:g 		\ % Mackel: Rink < Ring'
				| r [dt]:<> 	\ % Mackel: Peer < Peert

$MND_E$= $DEHNUNG$ $C$* | $DEHNUNG$? $UEBERLAENGE$ 


% note that we allow simplification of n\=en to n
$SURFACE$=  ($V$ | $C$ | [\=']:<> | {\=er}:r | {\=et}:t | {\=en}:n | $MND_E$ {\=e}:<> $C$ \ % from adj.fst
			| {n\=en}:n 													   \ % addendum for possessive pronouns
			)* ($MND_E$ ':<>)? 


$META$= ( reg 	% Regiolekt, sofern vom hd abweichend \
		| hd 	% Hochdeutsch, oder hochdeuter Einfluss \
		| mk    % Nordmärkische Merkmale nicht geteilt mit mp \
		| mp 	% Mittelpommersch dat statt märkisch det \
		| arch  % archaisch, veraltet, ältere Form \
		| ocr 	% für mögliche OCR-Fehler \
		| clit 	% klitisch \
		)

% inflection of possessive pronouns, extracted from strong inflection of adjectives
$INFLECT_POSS$= {DET}:{PRON} .* \. Poss \. (Sg (\. (Masc | Fem | Neut))? | Pl) \.:<> \ 
			( {Masc\.}:<> \
					( {Nom}:{\='} \			
					| {Nom\.emph}:{\=e} \	
					| {Nom\.hd}:{\=er} \	
					| {Acc}:{\=en} \		
					| {Nom}:{\='} \			
					| {Nom\.hd}:{\=er} \
					) \
			| {Neut\.}:<> \
					( {Nom}:{\='} \			
					| {Nom\.reg}:{\=et} \	% regiolekt
					| {Nom\.hd}:{\=es} \	% Mackel: "unter hochdeutschem Einfluss"					
					| {Acc}:{\='} \			
					| {Acc\.reg}:{\=et} \		
					| {Acc\.hd}:{\=es} \	% Mackel: "unter hochdeutschem Einfluss"					
					) \
			| {Fem\.}:<> \
					( {Nom}:{\='} \			
					| {Nom\.arch}:{\=e} \	% olle, Mackel: „noch nicht ganz verstummt“
					| {Acc}:{\='} \			
					) \
			| {Pl\.}:<> \					% I give both strong and weak forms here
					( {Nom}:{\=en} \	
					| {Nom}:{\='} \	
					| {Acc}:{\=en} \	
					| {Acc}:{\='} \	
					) \
			) \
			(\. $META$)*


$VALIDATE_TAGS$ = (PRON|DET) \
				\. (1 | 2 | 3 | Dem | Dem2 | Def | Ind | Refl ) \
				\. (Nom|Dat|Acc|Gen|Poss) \
				( \. (Pl | Sg ))? \
				( \. (Masc|Neut|Fem))? \
				( \. $META$)*


($INFLECT_POSS$ | $VALIDATE_TAGS$) || \
$DEEP$    || \
$SURFACE$
