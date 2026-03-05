$C$=[bdfghjklmnprstvwxS]
$V$=[aeiouEIOUöüÖÄÜœå] | au | ei | äu \
	| ou % ou to be confirmed \
	| [ää]:[ae] % diferent surface forms for underlying ä (a~e)

ALPHABET=$C$ $V$ [\?]

$PERSON$=[123_]
$NUMBER$=Sg|(Pl(_[a-z0]+)*)
$TENSE$=Prs|Prt
$MOOD$=Ind|Imp % not sure the Subj is still existent
$TYPE$=wk|st|arch|hd

$VFEATS$=VERB\.$PERSON$\.$NUMBER$\.$MOOD$\.$TENSE$(\.$TYPE$)* | \
		 VERB\.$PERSON$\.$NUMBER$\.Imp |\
		 VERB\.Inf(\_to)? | \
		 VERB\.PPast(\.$TYPE$)* \
		 VERB\.PPres % not sure the PPres is still existent

%%%%%%%%%%%%%%%%%%%%%
% dictionary lookup %
%%%%%%%%%%%%%%%%%%%%%

% note: sanity control by native word list and external dictionaries to be done independently
$VERB_LEX$=	.* / (VERB|AUX) [\/A-Za-z\.\_0-9\-]* 

%%%%%%%%%%%%%%%%%%%
% deep morphology %
%%%%%%%%%%%%%%%%%%%

% from morphological segmentation, map to morphosyntactic features and candidate lemma
% note that candidate lemmas overgenerate, so we need to ground this in a dictionary

% extrapolated from adpositions 
$SPLIT_VPART$=(nå	\
 			|up \
 			|uner \
 			|üm \
 			|mit \
 			|in \
 			|an \
 			|af \
 			|Ut \
 			|tO \
 			|fœr \
 			|bI \
 			|dörx \
 			|œver \
 			|axter \
 			|entgEgen\ % hd?
 			|gEgen\ % hd?
 			|fan \
 			|fon		\ % hd?	
 			% |tsu \ % hd!
 			) [\+]:<>
 
% extrapolated from the first three characters of verbs
$SPLIT_VPFX$	= (fer|fœr	\
 				| ge 		\
 				| be 		\
 				| ent 		\
 				| er 		\ % hd
 				) [\-]:<>

%%%%%%%%%%%%%%%%%%%
% weak inflection %
%%%%%%%%%%%%%%%%%%%
 
% the following includes the weak inflection, but also cases of strong inflection in present tense without vowel alternation
$WEAK$= $SPLIT_VPART$* ( $SPLIT_VPFX$? (.* {en/VERB\.}:<> ( {Inf}:{\=en}						\ % Infinitive
														 | {1\.Sg\.Ind\.Prs}:{\='} 				\ % hÖr
 														 | {2\.Sg\.Ind\.Prs}:{\=st} 			\ % hÖrst
 														 | {3\.Sg\.Ind\.Prs}:{\=t} 				\ % hÖrt
 														 | {3\.Sg\.Ind\.Prs\.arch}:{\=et} 		\ % hÖret (Jung, selten)
 														 | {\_\.Pl\.Ind\.Prs}:{\=en} 			\ % hÖren, måken
 														 | {1\.Sg\.Ind\.Prt\.wk}:{\=D} 			\ % not attested, but cf. 3.Sg
 														 | {1\.Sg\.Ind\.Prt\.wk\.hd}:{\=De} 	\ % hÖrte
 														 | {2\.Sg\.Ind\.Prt\.wk}:{\=Dest} 		\ % måktest (neben mökst)
 														 | {3\.Sg\.Ind\.Prt\.wk}:{\=D} 			\ % hÖrt, antwOrt (Dörr: antwurt't)
 														 | {3\.Sg\.Ind\.Prt\.wk\.arch}:{\=De} 	\ % hÖrte (mehrfach), anwOrte (Dörr: antwurt'te), kåkte (nur so)
 														 	% die eigentlich veraltete Form ist in der Schriftsprache überrepräsentiert, wohl weil sie zum Hochdeutschen stimmt \
 														 	% im Dialekt würde sie tendentiell eher insgesamt vermieden, insofern lasse ich "arch" bestehen \
 														 | {\_\.Pl\.Ind\.Prt\.wk}:{\=Den} 		\ % hÖrten, måkten
 														 | {2\.Sg\.Imp}:{\='}					\ % hÖr (Bornemann: hör'), seg (Jung: segg')
 														 | {2\.Sg\.Imp\.arch}:{\=e}				\ % hÖre (Bornemann), segge (Jung)
 														 | {2\.Pl\.Imp}:{\=t}					\ % hÖrt, segt
 														 | {PPast\.wk}:{\=t}					\ % uphÖrt
 														 | {PPast\.st}:{\=en}					\ % for strong inflection without vowel change
 														 ) \
 									 ) \
 						| <>:{ge\=} .* ( {en/VERB\.PPast\.wk\.arch\.hd}:{\=et}				\ % gehÖret (Jung, neben uphört)
 									  | {en/VERB\.PPast\.wk\.hd}:{\=t}						\ % gekåkt
 									  ) \
 						| <>:{ge\=} .* ( {en/VERB\.PPast\.st\.hd}:{\=en}						\ % for strong inflection without vowel change *here*
 									  ) \
 						| <>:{tO} .* {en/VERB\.}:<> {Inf\_to}:{\=en} 							\ % aftOmåken
 						)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% strong inflection and ablaut %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we distinguish ablaut classes in order to limit to plausible patterns 

% we skip identical forms in present because these would be covered by weak inflection
$ABLAUT_prs_1$ = I:i
$ABLAUT_prt_sg_1$ = I:E
$ABLAUT_prt_pl_1$ = I:E
$ABLAUT_ppast_1$ = I:Ä

$ABLAUT_prs_2$ = [EUÜ]:Ü | [EUÜ]:ü
$ABLAUT_prt_sg_2$ = [EUÜ]:O | [EUÜ]:Ö
$ABLAUT_prt_pl_2$ = [EUÜ]:O | [EUÜ]:Ö
$ABLAUT_ppast_2$ = [EUÜ]:å

$ABLAUT_prs_3$ = e:i
$ABLAUT_prt_sg_3$ = [ie]:a | [ie]:u | [ie]:ü 
$ABLAUT_prt_pl_3$ = [ie]:ü | [ie]:u 
$ABLAUT_ppast_3$ = [ie]:u | [ie]:o

$ABLAUT_prs_4$ = Ä:i | Ä:e
$ABLAUT_prt_sg_4$ = Ä:[åoeaö] 
$ABLAUT_prt_pl_4$ = Ä:[åœ] 
$ABLAUT_ppast_4$ = Ä:å

$ABLAUT_prs_5$ = Ä:i | Ä:e
$ABLAUT_prt_sg_5$ = [Äie]:a | [Äie]:Ä | [Äie]:E | [Äie]:Ö
$ABLAUT_prt_pl_5$ = [Äie]:a | [Äie]:Ä | [Äie]:E | [Äie]:Ö
$ABLAUT_ppast_5$ = [Äie]:Ä

$ABLAUT_prs_6$ = a:å | [aöå]:œ | å:a | [aåœ]:ö 
$ABLAUT_prt_sg_6$ = [aöåœ]:O | [aöåœ]:Ö | [aöåœ]:ü | [aåœ]:ö
$ABLAUT_prt_pl_6$ = [aöåœ]:O | [aöåœ]:Ö
$ABLAUT_ppast_6$ = [aöåœ]:a | [aöåœ]:å

$ABLAUT_prs_7a$ = å:e
$ABLAUT_prt_sg_7a$ = å:E 
$ABLAUT_prt_pl_7a$ = å:E 
$ABLAUT_ppast_7a$ = å:å

$ABLAUT_prs_7b$ = O:Ö | [ÖO]:ö | [ÖO]:ü
$ABLAUT_prt_sg_7b$ = [OÖ]:E |Ö:O 
$ABLAUT_prt_pl_7b$ = [OÖ]:E |Ö:O
$ABLAUT_ppast_7b$ = [OÖ]:O | [OÖ]:å

$ABLAUT$=	$ABLAUT_prs_1$ | $ABLAUT_prt_sg_1$ | $ABLAUT_prt_pl_1$ | $ABLAUT_ppast_1$ | \
			$ABLAUT_prs_2$ | $ABLAUT_prt_sg_2$ | $ABLAUT_prt_pl_2$ | $ABLAUT_ppast_2$ | \
			$ABLAUT_prs_3$ | $ABLAUT_prt_sg_3$ | $ABLAUT_prt_pl_3$ | $ABLAUT_ppast_3$ | \
			$ABLAUT_prs_4$ | $ABLAUT_prt_sg_4$ | $ABLAUT_prt_pl_4$ | $ABLAUT_ppast_4$ | \
			$ABLAUT_prs_5$ | $ABLAUT_prt_sg_5$ | $ABLAUT_prt_pl_5$ | $ABLAUT_ppast_5$ | \
			$ABLAUT_prs_6$ | $ABLAUT_prt_sg_6$ | $ABLAUT_prt_pl_6$ | $ABLAUT_ppast_6$ | \
			$ABLAUT_prs_7a$ | $ABLAUT_prt_sg_7a$ | $ABLAUT_prt_pl_7a$ | $ABLAUT_ppast_7a$ | \
			$ABLAUT_prs_7b$ | $ABLAUT_prt_sg_7b$ | $ABLAUT_prt_pl_7b$ | $ABLAUT_ppast_7b$

% only the endings, applied to the stem
$STRONG_FINITE_ENDING_PRS$=	( {1\.Sg\.Ind\.Prs}:{\='} 				\ % = (biet, geit, drink, help, sterw', nääm, äät, fang, gråw') 
 						   	| {2\.Sg\.Ind\.Prs.st}:{\=st}			\ % [IEÄå]>[iüiÖ] (bittst, güttst, nimmst, ittst, gröfst)
 																	\ % = (drinkst, helpst, sterwst, fangst)
 							| {3\.Sg\.Ind\.Prs.st}:{\=t} 			\ % ~ 2.Sg
 							| {3\.Sg\.Ind\.Prs\.st\.arch}:{\=et} 	\ % ~ weak
 							| {\_\.Pl\.Ind\.Prs}:{\=en} 			\ % ~ 1.Sg (= Inf)
						 	| {2\.Sg\.Imp\.st}:{\='}				\ % = (most), Ä>i (nimm, itt)
 							| {2\.Sg\.Imp\.arch}:{\=e}				\ % ~ weak
 							| {2\.Pl\.Imp\.st}:{\=t}				\ % ~ 2.Sg
 							)

$STRONG_FINITE_ENDING_PRT_SG$=	( {1\.Sg\.Ind\.Prt\.st}:{\='} 		\ % [IEieÄÄaå]>[EÖüüEaüÖ] (beit, gäut, drünk, hülp, 
																	\ % stürw, neim/namm, eit/att, füng, gräuw')
								| {2\.Sg\.Ind\.Prt\.st}:{\=st} 		\ % ~ 1.Sg
								| {3\.Sg\.Ind\.Prt\.st}:{\='} 		\ % ~ 1.Sg
								)

$STRONG_FINITE_ENDING_PRT_PL$=	( {\_\.Pl\.Ind\.Prt\.st}:{\=en} ) 	\ % ~ 1.Sg

$STRONG_FINITE_ENDING_PPAST$=	( {PPast\.st}:{\=en} )				\ % [IEieeÄÄaå]>[ÄåuuoåÄuå] (bääten, gåten, drunken, hulpen, 
																	\ % storm', nåm', ääten, fung', gråm')

% Lemmas by Mackel, Ablaut extrapolated from corpus and Mackel, only monosyllabic
% this is limited to monosyllabic stems, right now, lemmas from Mackel (https://de.wikipedia.org/w/index.php?title=Nordm%C3%A4rkisch&stable=1#Bildung_von_Verben)
$STRONG$= $SPLIT_VPART$* \
	( ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_1$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.i}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_2$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.ii}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_3$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.iii}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_4$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.iv}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_5$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.v}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_6$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.vi}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_7a$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.viia}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prs_7b$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRS$  	{\.viib}:<> )	\
 	\
 	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_1$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.i}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_2$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.ii}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_3$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.iii}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_4$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.iv}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_5$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.v}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_6$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.vi}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_7a$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.viia}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_sg_7b$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_SG$  	{\.viib}:<> )	\
 	\
 	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_1$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.i}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_2$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.ii}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_3$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.iii}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_4$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.iv}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_5$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.v}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_6$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.vi}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_7a$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.viia}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_prt_pl_7b$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PRT_PL$  	{\.viib}:<> )	\
 	\
 	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_1$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.i}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_2$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.ii}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_3$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.iii}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_4$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.iv}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_5$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.v}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_6$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.vi}:<> )		\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_7a$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.viia}:<> )	\
	| ( $SPLIT_VPFX$? 	$C$* $ABLAUT_ppast_7b$ $C$* 	(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.viib}:<> )	\
 	\
 	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_1$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.i}:<> 	{\.hd}:<> )		\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_2$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.ii}:<> 	{\.hd}:<> )		\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_3$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.iii}:<> 	{\.hd}:<> )	\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_4$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.iv}:<> 	{\.hd}:<> )		\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_5$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.v}:<> 	{\.hd}:<> )		\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_6$ $C$* 			(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.vi}:<> 	{\.hd}:<> )		\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_7a$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.viia}:<> {\.hd}:<> )	\
	| ( <>:{ge\=} 	$C$* $ABLAUT_ppast_7b$ $C$* 		(e:<>)? {n/VERB\.}:<> $STRONG_FINITE_ENDING_PPAST$  	{\.viib}:<> {\.hd}:<> )	\
 	\
 	| ( <>:{tO} 		.* 								(e:<>)? {n/VERB\.}:<> {Inf\_to}:{\=en})				\
 	)

 
$DEEP$=$WEAK$ | $STRONG$ 

%%%%%%%%%%%%%%%%%%%%
% surface analysis %
%%%%%%%%%%%%%%%%%%%%
% based on norm, we insert lengthening signs and morpheme separators
 
$SURFACE_MID$ = .  | [=+\-]:<> | ':<>  	\ % defaults
 			 | b [+\-=]:<> b:<> 	\ % restore double consonants
 			 | d [+\-=]:<> d:<> 	\ % restore double consonants and undo assimilations
 			 | d [+\-=]:<> D:<> 	\ % restore double consonants and undo assimilations
 			 | d:[dt] [+\-=]:<> t:<> 	\ % restore double consonants and undo assimilations
 			 | f [+\-=]:<> f:<> 	\ % restore double consonants and undo assimilations
 			 | g [+\-=]:<> g:<> 	\ % restore double consonants and undo assimilations
 			 | k [+\-=]:<> k:<> 	\ % restore double consonants and undo assimilations
 			 | l [+\-=]:<> l:<> 	\ % restore double consonants and undo assimilations
 			 | m [+\-=]:<> m:<> 	\ % restore double consonants and undo assimilations
 			 | n [+\-=]:<> n:<> 	\ % restore double consonants and undo assimilations
 			 | p [+\-=]:<> p:<> 	\ % restore double consonants and undo assimilations
 			 | r [+\-=]:<> r:<> 	\ % restore double consonants and undo assimilations
 			 | s [+\-=]:<> s:<> 	\ % restore double consonants and undo assimilations
 			 | t [+\-=]:<> D:<> 	\ % anwOrte (Dörr: antwurt'te)
 			 | {t\=t}:{st} 			\ % müst
 			 | [dt] [+\-=]:<> t:<> 	\ % restore double consonants and undo assimilations
 			 % | v [+\-=]:<> v:<> 	\ % doesn't occur
 			 | x [+\-=]:<> x:<> 	\ % -"-
 			 | t {\=D}:<> 			\ % 
 			 | $C$ {\=D}:t 			\ % hÖrt ("er hörte"), kåkte "es kochte", seggten
 
$SURFACE_END$ = $C$ {n\='}:{en} 		\ % sEgen "ich segne" (Bornemann 1816) 
 			 | $C$ {n\='}:{ne}		\ % sEgne "ich segne" (Bornemann 1868)
 			 | $C$ {n\=st}:{nest}	\ % sEgnest (by analogy)
 			 | $C$ {n\=t}:{net}		\ % sEgnet "er segnet" (Bornemann 1810)
 			 | $C$ {\=en}:n 			\ % måkn, hÖrn, segn (mehrfach)
 
$SURFACE$=$SURFACE_MID$* $SURFACE_END$?
 
%%%%%%%%%%%%%%
% norm2lemma %
%%%%%%%%%%%%%%

($VERB_LEX$ \. [a-zA-Z0-9\+\_\-\.]*) \
|| $DEEP$ \
|| $SURFACE$ \ 

% note: sanity control by external dicts still to be done
% "roots.dic"					 | \ % inferred from lexemes
%	"lexemes.dic"				 | \ % directly attested
%	"verbs.dic"					     % from ../morph/verbs.dic

