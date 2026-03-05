$V$=[aeiouäöüÖÄÜEIOUœå]
$C$=[bdfghjklmnprstvwxS]
ALPHABET=$C$ $V$ [\-\+] [áéíóú]:[aeiou] [a-z0-9A-Z\.\_"]

$POS$=ADJ|ADP|ADV|AUX|CCONJ|DET|INTJ|NOUN|NUM|PART|PRON|PROPN|VERB
$FEATS$=Acc|Cpv|Dat|Def|Dem|Dem2|Fam|Fem|Fut|Gen|Imp|Ind|Inf|Inf_to|Masc|Neg|Neut|Nom|Pl(_overl|_0|_e|_en|_er|_s|_uml)*|Pos|Poss|PPast|Pred|Prs|Prt|Refl|Sbj|Sg|Spv|Sub|Subj|Tot|[_0-9]

$FLAGS$=arch|clit|emph|frz|full|hd|hyper|mp|ocr|reg|st|wk

$ANNO$=$POS$(\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*

%%%%%%%%%
% FILES %
%%%%%%%%%

$ROOTS$="roots.dic"
$LEXEMES$="lexemes.dic"

%%%%%%%%%%%%%%%%%%%%%%%%%%
% morphological pocesses %
%%%%%%%%%%%%%%%%%%%%%%%%%%

$UMLAUT$= .* ([äaaouOUå]:[eeäöüÖÜœ] | {au}:{äu}) $C$* 

$TONDEHNUNG$ = .* ([aeiouöäü]:[åÄÄåUœÄÜ]) $C$?

$AUSLAUTVERHAERTUNG$ = .* (d:t|g:x|v:f)? \
						% Schreibung ist optional

$ASSIMILATION$	= % front assimilations: syncope \
				  ({ge}:{g} [snl])? \ % _gesel_ ~ _gsel_, _gnÖgen_ ~ _genÖgen_, _glÖven_ ~ _(ge)lÖven_   
				  % obstruent softening: middle assimilations
				  (. 			% all assimilations are modelled as being optional  \
				  | [nlr] d:<> $V$ 	% münig < mund, Sulix < Suld, warn < warden \
				  )* \
				  || \
				  $AUSLAUTVERHAERTUNG$
				  % ?orthographically inverted auslautverhärtung \

% not integrated yet

%%%%%%%%%%%%%%%%%%%%%%%%%%
% prefixes and particles %
%%%%%%%%%%%%%%%%%%%%%%%%%%

$PFX_V$	=	( be 		% be-Ögen \
	 		| ent 		% ent-gån \
	 		| er 		% er-barmen \
	 		| fer 		% fer-SlUten \
	 		| ge 		% ge-horken \
	 		| ter 		% ter-rIten \
	 		) 

$PFX_N$	=	( un	% un-frEd \
	 		| ur 	% ur-tEl? \
	 		| fœr 	% fœr-Ölern \
			) 

$PFX_A$	= 	( un 		% un-Sülix \
			| ur 		% ur-olt \
			) 

 % the following are particles and original prepositions we also find in derived nouns
$VPART$	= Ut % Ut+Slaxten \
		| af % af+SnIden \
		| an % an+fåten \
		| bI % bI+paken \
		| dörx % dörx+helpen \
		| entgEgen	% entgEgen(?)+wanken \
		| fœr	% fœr+nEmen \
		| fœrbI % fœrbi+lOpen \
		| hen % hen+lOpen \
		| in % in+bringen \
		| ran % ran+kåmen \
		| rin % rin+krUpen \
		| tO % tO+Slågen \
		| uner % uner+krIgen \
		| up % up+rixten \
		| weder % cf. weder+rÄd (N), German widersprechen \
		| weg % weg+helpen \
		| üm % üm+binnen \

$NPART$	= Ut % Ut+stÜr \
		| af % af+gang \
		| al % al+maxt \
		| an % an+fang \
		| axter % axter+sId \
		| bI % bI+stand \
		| dörx % cf. dörx+helpen and German Durchfall \
		% | entgEgen % cf. entgEgen(?)+wanken and German Entgegenkommen\
		| fœr % fœr+Slag \
		% | fœrbI % cf. fœrbi+lOpen \
		% | hen % cf. hen+lOpen \
		| in % cf. in+bringen and German Einlauf \
		% | ran % ran+kåmen \
		% | rin % rin+krUpen \
		| tO % cf. tO+Slågen and German Zufall \
		| uner % uner+gang \
		| up % up+stand \
		| weder % weder+rÄd \
		% | weg % cf. weg+helpen \
		| üm % cf. üm+binnen and German Umstand \

$APART$ = af 		% af+günstig \
		| Uter 		% Uter+gewÖnlix

%%%%%%%%%%%%%%%%
% base entries %
%%%%%%%%%%%%%%%%

% restored lexical grounding, necessary for tracking multiple stems
$NUM$ = $ROOTS$ || ...* / NUM (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*
$PROPN$ = $ROOTS$ || ...* / PROPN (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*
$AUX$ = $ROOTS$ || ...* / AUX (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*

#include "participles.fst"
% => $PARTICIPLE$

$VERB0$=($VPART$ [+]:<>)? ($PFX_V$ [-]:<>)? ($ROOTS$ || ...* / (VERB|AUX) (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*) 
$NOUN0$= ( ($NPART$ [+]:<>)? ($PFX_N$ [-]:<>)? ($ROOTS$ || ...* / NOUN (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*)) \
		 | $PROPN$
$ADJ0$= ( ($APART$ [+]:<>)? ($PFX_A$ [-]:<>)? ($ROOTS$ || ...* / ADJ (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*) ) \
		| $NUM$ \
		| (( ($VPART$ [+]:<>)? (<>:{ge}|($PFX_V$ [-]:<>))? ($ROOTS$ || ...* / VERB (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*) || .* (e:<>)? n:t / ([a-zA-Z0-9_\.]:<>)*) {\.PPast\.wk/ADJ}:<>) \
			% verekt, gedekt \
		| ($PARTICIPLE$ / ADJ)

$ADV0$= ($C$|$V$|[+\-])* / AD [VV]:[VJ] (\.$FEATS$([?]:<>)?)*(\.$FLAGS$(<>:[?])?)* || ($ROOTS$ || ...* / AD[VJ] (\.$FEATS$([?]:<>)?)*(\.$FLAGS$([?]:<>)?)*)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% derivation and compounding %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$NOUN1$	\
   = ($NPART$ [+]:<>)? ($PFX_N$ [-]:<>)? \
     ( \		
		(((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) (\-:<> (en|n|es|s|er))? [\+]:<>)* ($NOUN0$)) \
	 			% Er-en+pOrt, SwIn+stal, SwIns+kop, SnIdergsel, dOdes+angst \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> er /NOUN\.Masc ) \
				% aptEker \
		| (( <>:{ge}) (($NOUN0$) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> {ge\.\.\.\"}:<> /NOUN\.Neut ) \
				% gemÖt \
		| ((($NOUN0$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> er /NOUN\.Masc ) \
				% mörder \
		| ((($NOUN0$ ) || .* er /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> I /NOUN\.Fem ) \
				% dokterI \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> erI /NOUN\.Fem ) \
				% hekserI \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)* {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* ) \-:<> (es) /NOUN\.Fem\.frz ) \
				% printses \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)* {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* ) \-:<> (esin) /NOUN\.Fem\.hd ) \
				% printsesin \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)+ {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* )  \-:<> (in|n) /NOUN\.Fem ) \
				% frÜndin, meistern \
	 	| (((($ADJ0$ | $NUM$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) [\+]:<>)* ($NOUN0$)) \
	 			% dik+kop, EnhOrn \
	 	| ((($ADJ0$ | $NUM$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (keit|heit)/NOUN\.Fem)  \
	 	  		% Enigkeit, Enheit, wårheit \
	 	| (((($VERB0$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) {\.Inf}:<>/NOUN\.Neut)) \
	 			% Senken\
	 	| (((($VERB0$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) {\.Inf\-}:<> t /NOUN\.Neut)) \
	 			% Ätent\
	 	| (((($VERB0$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> er /NOUN\.Masc)) \
	 			% SlIker\
	 	| (((($VERB0$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) /NOUN\.Masc)) \
	 			% fang\
	 	| (((($VERB0$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% anspÄlung\
	 	| (((($VERB0$) || .* [^e] (e:<>)? n /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% rÄknung\
	 	| (((($ADJ0$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% festung\
	 	| (((($VERB0$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> nis /NOUN\.Neut)) \
	 			% ferlÖvnis, ärgernis \
	 	| ( <>:{ge} ((($VERB0$) || .* [^e] (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) {\.ge\-\.\.\.abl}:<> /NOUN\.Neut)) \
	 			% gewEr, gewEv \
	 	| ( ( $ADJ0$ ||  .* /:<> ([a-zA-Z0-9_\.]:<>)*)  / NOUN ) \
	 			% we can do that always ;) \
		| ( ( $ADJ0$ || .* S /:<> ([a-zA-Z0-9_\.]:<>)*) / NOUN\.Fem ) \
				% olS, esp. for feminina \
	 )

$ADJ1$	\
  = \
  ($APART$ [+]:<>)? ($PFX_A$ [-]:<>)? \
  ( ((($NOUN0$ ) || .* (e:<>)? l /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix) / ADJ)  \
			% Smudlix, Sriftlix \
		| ( ( ($ADV0$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \+:<>)* $ADJ0$ ) \
			% hochdÜtS, platdÜtS \
		| ((($ADJ0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|ix) / ADJ)  \
			% apartix \
		| ((($ADJ0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (såm) / ADJ)  \
			% langsåm \
		| ((($ADJ0$ | $NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (lix) / ADJ) \
			% Eniglix, Erlix, SwErlix  \
		| ((($ADJ0$ | $NOUN0$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (lix) / ADJ) \
			% krenklix  \
		| ((($NOUN0$ ) || (.* ) {en}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ern) / ADJ) \
			% cf. knœkern  \
		| ((($NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \+:<> (los) / ADJ) \
			% cf. gotlOs  \
		| ((($NOUN0$ ) || (.* || $UMLAUT$) {en}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (ern) / ADJ) \
			% knœkern  \
	 	| ((($VERB0$ | $AUX$) || .* ({el}:<>|{le}:<>|e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> lix /ADJ) \
	 		% bewEglix, betrÜglix, cf. mœglix, (bÖs)wilix; waklix \
	 	| ((($VERB0$ ) || (.* || $UMLAUT$) ({el}:<>|{le}:<>|e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> lix /ADJ) \
	 		% grÜlix \
	 	| ((($VERB0$ ) || (.* || $UMLAUT$) (e:<>)? {n}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% lexerlix \
	 	| ((($NOUN0$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% fürxterlix \
	 	| ((($VERB0$ ) || .*  (e:<>)? {n}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% cf. hd. weinerlix \
		| ((($ADV0$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) [\+]:<>)? (($VERB0$ | $AUX$) || .* (l:<>)? (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> lix /ADJ) \
	 		% bÖswilix \
		| ((( $NOUN0$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix|S) / ADJ) \
			% Isig, Ilig, dOdig, fIndlix, tükS \
		%| ( (ge \-:<>)? (( $NOUN0$ ) || $AUSLAUTVERHAERTUNG$ /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (lix) / ADJ) \
			% cf. gemÖtlix \
		%| ( (ge \-:<>)? (( $NOUN0$ ) || ($AUSLAUTVERHAERTUNG$ || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (lix) / ADJ) \
			% gemÖtlix \
		| ((( $NOUN0$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ":<> (ig|lix|S) / ADJ) \
			% nÖdig, hÖnS \
		| ((( $PROPN$ | $NOUN0$ | $ADJ0$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (S) / ADJ) \
			% branbOrgS, olS (also for nouns) \
		| ((( $PROPN$  ) || .* ({Ien}:<>|I:<>|{jen}:<>|{en}:<>) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (S) / ADJ) \
			% spånS, türkS, präusS \
		 | (((($VERB0$) || .* [^e] (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> S /ADJ)) \
			% glÖvS \
		| ((( $ADV0$ ) || .* ( (l:<>)? s:<>)? /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix) / ADJ) \
			% dåmålix \
		| (($NUM$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> t/ADJ) \
			% teint, twEt (but not drüt) \
	)

$VERB1$ \
  = ($VPART$ [+]:<>)? ($PFX_V$ [-]:<>)? \		
  	( (( $NOUN0$ || (.* /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> (e|e:<>) n /VERB) \
  		% Eren \
  	| (( ($NOUN0$ | $ADV0$) || (($UMLAUT$ ) /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> \":<> (e|e:<>) n /VERB) \
  		% wünSen, genÖgen \
  	| (( $NOUN0$ || ($UMLAUT$ /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> \":<> ern /VERB) \
  		% SnÜtern \
  	| (( $NOUN0$ || (.* /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> igen /VERB) \
  		% pInigen \
  	| (( $NOUN0$ || ($UMLAUT$ /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> \":<> igen /VERB) \
  		% nÖdigen \
  	| (( $ADJ0$ || ($UMLAUT$ /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<> \":<> (e|e:<>) n /VERB) \
  		% wärmen \
  	| (( $ADJ0$ || (.* /:<> ([a-zA-Z0-9_\.]:<>)*) ) \-:<>  (e|e:<>) n /VERB) \
  		% cf. wärmen \
  	)

% 2nd iteration

$NOUN2$	\
   = ($NPART$ [+]:<>)? ($PFX_N$ [-]:<>)? \
     ( \		
		((((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) (\-:<> (en|n|es|s|er))? [\+]:<>)* (($NOUN0$|$NOUN1$))) \
	 			% Er-en+pOrt, SwIn+stal, SwIns+kop, SnIdergsel, dOdes+angst \
		| (((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> er /NOUN\.Masc ) \
				% aptEker \
		| (( <>:{ge}) ((($NOUN0$|$NOUN1$)) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> {ge\.\.\.\"}:<> /NOUN\.Neut ) \
				% gemÖt \
		| (((($NOUN0$|$NOUN1$) ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> er /NOUN\.Masc ) \
				% mörder \
		| (((($NOUN0$|$NOUN1$) ) || .* er /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> I /NOUN\.Fem ) \
				% dokterI \
		| (((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> erI /NOUN\.Fem ) \
				% hekserI \
		| (((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)* {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* ) \-:<> (es) /NOUN\.Fem\.frz ) \
				% printses \
		| (((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)* {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* ) \-:<> (esin) /NOUN\.Fem\.hd ) \
				% printsesin \
		| (((($NOUN0$|$NOUN1$) ) || .* /:<> ([a-zA-Z0-9_\.]:<>)+ {\.Masc}:<> ([a-zA-Z0-9_\.]:<>)* )  \-:<> (in|n) /NOUN\.Fem ) \
				% frÜndin, meistern \
	 	| (((($ADJ1$ | $NUM$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) [\+]:<>)* (($NOUN0$|$NOUN1$))) \
	 			% dik+kop, EnhOrn \
	 	| ((($ADJ1$ | $NUM$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (keit|heit)/NOUN\.Fem)  \
	 	  		% Enigkeit, Enheit, wårheit \
	 	| (((($VERB1$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) {\.Inf}:<>/NOUN\.Neut)) \
	 			% Senken\
	 	| (((($VERB1$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) {\.Inf\-}:<> t /NOUN\.Neut)) \
	 			% Ätent\
	 	| (((($VERB1$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> er /NOUN\.Masc)) \
	 			% SlIker\
	 	| (((($VERB1$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) /NOUN\.Masc)) \
	 			% fang\
	 	| (((($VERB1$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% anspÄlung\
	 	| (((($VERB1$) || .* [^e] (e:<>)? n /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% rÄknung\
	 	| (((($ADJ1$) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ung /NOUN\.Fem)) \
	 			% festung\
	 	| (((($VERB1$) || .* (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> nis /NOUN\.Neut)) \
	 			% ferlÖvnis, ärgernis \
	 	| ( <>:{ge} ((($VERB1$) || .* [^e] (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) {\.ge\-\.\.\.abl}:<> /NOUN\.Neut)) \
	 			% gewEr, gewEv \
	 	| ( ( $ADJ1$ ||  .* /:<> ([a-zA-Z0-9_\.]:<>)*)  / NOUN ) \
	 			% we can do that always ;) \
		| ( ( $ADJ1$ || .* S /:<> ([a-zA-Z0-9_\.]:<>)*) / NOUN\.Fem ) \
				% olS, esp. for feminina \
	 )


$ADJ2$	\
  = \
  ($APART$ [+]:<>)? ($PFX_A$ [-]:<>)? \
  ( ((($NOUN1$ ) || .* (e:<>)? l /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix) / ADJ)  \
			% Smudlix, Sriftlix \
		| ( ( ($ADV0$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \+:<>)* $ADJ1$ ) \
			% hochdÜtS, platdÜtS \
		| ((($ADJ1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|ix) / ADJ)  \
			% apartix \
		| ((($ADJ1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (såm) / ADJ)  \
			% langsåm \
		| ((($ADJ1$ | $NOUN1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (lix) / ADJ) \
			% Eniglix, Erlix, SwErlix  \
		| ((($ADJ1$ | $NOUN1$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (lix) / ADJ) \
			% krenklix  \
		| ((($NOUN1$ ) || (.* ) {en}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ern) / ADJ) \
			% cf. knœkern  \
		| ((($NOUN1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \+:<> (los) / ADJ) \
			% cf. gotlOs  \
		| ((($NOUN1$ ) || (.* || $UMLAUT$) {en}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (ern) / ADJ) \
			% knœkern  \
	 	| ((($VERB1$ | $AUX$) || .* ({el}:<>|{le}:<>|e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> lix /ADJ) \
	 		% bewEglix, betrÜglix, cf. mœglix, (bÖs)wilix; waklix \
	 	| ((($VERB1$ ) || (.* || $UMLAUT$) ({el}:<>|{le}:<>|e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> lix /ADJ) \
	 		% grÜlix \
	 	| ((($VERB1$ ) || (.* || $UMLAUT$) (e:<>)? {n}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% lexerlix \
	 	| ((($NOUN1$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% fürxterlix \
	 	| ((($VERB1$ ) || .*  (e:<>)? {n}:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> erlix /ADJ) \
	 		% cf. hd. weinerlix \
		| ((($ADV0$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) [\+]:<>)? (($VERB1$ | $AUX$) || .* (l:<>)? (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> lix /ADJ) \
	 		% bÖswilix \
		| ((( $NOUN1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix|S) / ADJ) \
			% Isig, Ilig, dOdig, fIndlix, tükS \
		%| ( (ge \-:<>)? (( $NOUN1$ ) || $AUSLAUTVERHAERTUNG$ /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (lix) / ADJ) \
			% cf. gemÖtlix \
		%| ( (ge \-:<>)? (( $NOUN1$ ) || ($AUSLAUTVERHAERTUNG$ || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> \":<> (lix) / ADJ) \
			% gemÖtlix \
		| ((( $NOUN1$ ) || (.* || $UMLAUT$) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> ":<> (ig|lix|S) / ADJ) \
			% nÖdig, hÖnS \
		| ((( $PROPN$ | $NOUN1$ | $ADJ1$ ) || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (S) / ADJ) \
			% branbOrgS, olS (also for nouns) \
		| ((( $PROPN$  ) || .* ({Ien}:<>|I:<>|{jen}:<>|{en}:<>) /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (S) / ADJ) \
			% spånS, türkS, präusS \
		 | (((($VERB1$) || .* [^e] (e:<>)? n:<> /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> S /ADJ)) \
			% glÖvS \
		| ((( $ADV0$ ) || .* ( (l:<>)? s:<>)? /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> (ig|lix) / ADJ) \
			% dåmålix \
		| (($NUM$ || .* /:<> ([a-zA-Z0-9_\.]:<>)*) \-:<> t/ADJ) \
			% teint, twEt (but not drüt) \
	)

$ADV2$=($ADJ1$|$ADJ2$ || .* /:<> [a-zA-Z0-9\_\.]:<>)* / ADV

%%%%%%%%%%%%%%%%%
% HOW TO USE IT %
%%%%%%%%%%%%%%%%%

% import *.fst or *.a file
% call one or more of the following transducers
% we recommend to cascade for depth

% % PRODUCTION: include POS tags
% $PRODUCTION$ =\
% 	( $VERB0$ \
% 	| $VERB1$ \
% 	| $NOUN0$ \
% 	| $NOUN1$ \
% 	| $NOUN2$ \
% 	| $ADJ0$ \
% 	| $ADJ1$ \
% 	| $ADJ2$ \
% 	| $ADV0$ \
% 	| $ADV2$ \
% 	| $NUM$ \
% 	| $AUX$ \
% 	| $PROPN$ \
% 	%| ((($ROOTS$ ([?]:<>)? || ([^+\-] | [+\-]:<> )*) || $ASSIMILATION$)) \
% 	| (((($LEXEMES$|$ROOTS$) ([?]:<>)? || ([^+\-] | [+\-]:<> )*) || $ASSIMILATION$)) \
% 	) % / $ANNO$))
% 
% % DEBUG: norm string (no POS) to all possible analyses
% $DEBUG$= \
% 	$PRODUCTION$ || ...* /:<> ([a-zA-Z0-9_\.]:<>)* \
% 
% %%%%%%%%%%%%%%
% % calling it %
% %%%%%%%%%%%%%%
% 
% %$DEBUG$ | $PRODUCTION$ 
% $PRODUCTION$