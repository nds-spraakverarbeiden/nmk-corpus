$V$=[aäeiouöüEIOUÄÖÜåœ] | au | ei | äu | ou % ou tbc
$C$=[bdfghjklmnprstvwxS]
ALPHABET=$V$ $C$ [\-\.A-Za-z\_\=\/]

% basiert auf Mackel (1905, vgl. https://de.wikipedia.org/wiki/Nordm%C3%A4rkisch#Konjugation)

% we use noun classes for GENDER (for sg), resp., NUMBER (pl only)
$CLASS$=Masc|Fem|Neut|Pl

% there is no morphological dative for adjectives, but for synthesizing training data over
% German corpora, we need dative agreement
% genitive is added, but morphosyntactically, these are effectively adverbs
$CASE$=Nom|Dat|Acc|Gen

$NFEATS$=$CLASS$\.$CASE$

%%%%%%%%%%%%%%%%%
% lexeme lookup %
%%%%%%%%%%%%%%%%%
% drop lexeme lookup, do filtering, instead

$ADJ_LEX$	= .* / (ADJ) (\.[\/A-Za-z\.\_0-9\-]+)? 

%%%%%%%%%%%%%%%%%%%
% deep inflection %
%%%%%%%%%%%%%%%%%%%

% st: starke flexion, nach unbestimmtem artikel
% wk: schwach, nach bestimmtem artikel
$INFLECT$=.*{/ADJ\.}:<> \
			( {Masc\.}:<> \
					( {Nom}:{\='} \			% Mackel gibt die Form als "oll" an, das ist analogisch aus olde ausgeglichen 
					| {Nom\.emph}:{\=e} \	% olle, Mackel: Du olle gråwe Hunt! „Du alter grober Hund“
					| {Nom\.st\.hd}:{\=er} \	% oller (Mackel: "der Schriftsprache nachgebildet")
					| {Acc}:{\=en} \		% ollen
					| {Nom}:{\='} \			% Mackel gibt die Form als "oll" an, das ist analogisch aus olde ausgeglichen 
					| {Nom\.st\.hd}:{\=er} \	% oller (Mackel: "der Schriftsprache nachgebildet")
					) \
			| {Neut\.}:<> \
					( {Nom\.wk}:<> \		% oll (olt), nur schwach
					| {Nom}:{\='} \			% Mackel gibt die Form als "oll" an, das ist analogisch aus olde ausgeglichen 
					| {Nom\.st\.reg}:{\=et} \		% regiolekt
					| {Nom\.st\.hd}:{\=es} \		% Mackel: "unter hochdeutschem Einfluss"					
					| {Acc\.wk}:<> \			% oll (olt)
					| {Acc}:{\='} \			% Mackel gibt die Form als "oll" an, das ist analogisch aus olde ausgeglichen 
					| {Acc\.st\.reg}:{\=et} \		% regiolekt
					| {Acc\.st\.hd}:{\=es} \		% Mackel: "unter hochdeutschem Einfluss"					
					) \
			| {Fem\.}:<> \
					( {Nom}:{\='} \			
					| {Nom\.arch}:{\=e} \	% olle, Mackel: „noch nicht ganz verstummt“
					| {Acc}:{\='} \			% oll
					) \
			| {Pl\.}:<> \	% I might have gotten the following wrong
					( {Nom\.wk}:{\='} \			
					| {Nom\.st}:{\=en} \	
					| {Acc\.wk}:{\='} \
					| {Acc\.st}:{\=en} \	
					) \
			)

% von nouns.fst
$UMLAUT$= a:e \
		| å:œ \
		| o:ö \
		| u:ü \
		| O:Ö \
		| U:Ü \
		| {au}:{äu} \
		| {ou}:{äu} \ % if that does exist

$DEGREE$=.* $UMLAUT$? $C$* <>:{\=er} / ADJ {\.Cpv}:<> .* | \ % comparative
		 .* $UMLAUT$? $C$* <>:{\=est} / ADJ {\.Spv}:<> .* | \ % superlative
		 .* $UMLAUT$? $C$* <>:{\=st} / ADJ {\.Spv}:<> .* | \ % superlative
		 . * / ADJ {\.Pos}:<> .* 						\ % positive

%%%%%%%%%%%%%%%%%%%%%%
% surface generation %
%%%%%%%%%%%%%%%%%%%%%%

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


$SURFACE$= ($V$ | $C$ | [\=']:<> | {\=er}:r | {\=en}:n | $MND_E$ {\=e}:<> $C$ )* ($MND_E$ ':<>)?

%#############
% norm2lemma #
%#############

$ADJ_LEX$ .* || \
[^=]*\/ .* || \
	$DEGREE$ || \
	$INFLECT$ || \
	$SURFACE$
