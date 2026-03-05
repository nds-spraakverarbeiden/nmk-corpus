%%%%%%%%%%%%%%%%%%%%
% output inventory %
%%%%%%%%%%%%%%%%%%%%

$C$=[bdfghjklmnprstvwxS]
$SEP$='
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu

%%%%%%%%%%%%%%%%%%%%
% overall alphabet %
%%%%%%%%%%%%%%%%%%%%

ALPHABET=['aäbcdefghijklmnoöpqrsßtuüvwxz\-] \
	a:[Åå] ä:[Åå] œ:[æÆ] œ:[øØ] o:[øØ] \ 	% recurring OCR errors; TODO: fix manually
	i:y j:y \ % Apolyon?, dyn (eine alte Inschrift zitierend) 
	$C$ $V$ $SEP$ \_ 		% output and control symbols

%%%%%%%%%%%%%%%%
% author rules %
%%%%%%%%%%%%%%%%

$ASSIM$= \
		' v:b $V$	% œberall, dissimilation, actually; isn't obligatory, cf. tobieten \
	|	O:U r 		% Antwurt \
	| 	O:u r 		% Antwurt \
	| 	Ö:Ü r 		% by analogy \
	| 	Ö:ü r 		% by analogy \
	|	E:I r 		% tbc. \
	| 	E:i r 		% tbc.

$CONS$= $C$ | \
	f:v | \ % wovel, vull
	v:v | \ % äver
	k:{ck} | \ % Klock
	S:{sch} | \ % fuschern
	x:{ch} | \ % bröcht, achtteinten
	k:c    | \ % Doctor
	g:{gk} | \ % Königk (this is marking Auslautverhärtung)
	{kw}:{qu} |\ % Näsenquetscher
	b (<>:b)? | \
	d (<>:d)? | \
	f (<>:f)? | \
	g (<>:g)? | \
	k (<>:k)? | \
	l (<>:l)? | \
	m (<>:m)? | \
	n (<>:n)? | \
	p (<>:p)? | \ 
	r (<>:r)? | \
	s (<>:s)? | \
	s:ß |\
	t (<>:[th])? | \ % uth, Bokett
	{ts}:z  |\
	{ts}:{tz} |\
	w | \ % Antwurt
	v:w % Erw, fiew

% note that the following operates on syllab output, not on plain text
$LONG_VOWEL$=\
		å 			\ % from syllab
		| å:{aa} 	\ % gaan
		| å:{ah}	\ % tobettgahn
		| Ä:{äh}	\ % mähgen
			| au  		\ % Auktschon, Augustdag
		| {äu}:{äu} \ % genäusten ?
		| E:{ee} 	\ % Been, Deel, een
		| E:{eh}	\ % nehm
		| ei (<>:h)?	\ % beid, deiht, Eenigkeit
		| {äu}:{eu}		\ % Freud
		| I:{ie} (<>:h)?	\ % fiew, Fiehn
		| Ö:{öö}	\ % föört, möösam
		| Ö:{öh}	\ % föhrt, möhsam
		| Ö:{oe}	\ % Oestreich
		| œ:{oe}	\ % oeberlopen
		| œ:{œh}	\ % Sœhn
		| O:{oo}	\ % Stool, doon
		| O:{oh}	\ % Koh
		| å:{oh}	\ % Rotspohn ?
		| U:{uu}	\ % Buur, suur
		| U:{uh}	\ % ruhgen, Upruhr
		| Ü:{üh}	\ % süh
		| Ü:{üü}	\ % utfüürlich
		| Ü:{ü'e} \ % düer

$SHORT_VOWEL_OPEN$= \
		å:a 	\ % baben, dabi
	| 	Ä:ä 	\ % Mäken
	| 	œ:ä 	\ % äver ?
	| 	E:e 	\ % œberg*e*ben
	| 	e:e 	\ % b*e*dreegen, Depeschendräger
	|	i 		\ % œbrigens, in unstressed syllables
	| 	I:i 	\ % finen, dinen, ilig
	|	O:o 	\ % grote
	| 	o 		\ % ümtodohn, in unstressed syllables
	| 	Ö:ö 	\ % anstöten; no short ö here
	| 	U:u 	\ % bruken
	| 	u 		\ % fuschern, Muschler
	| 	Ü:ü 	\ % grülich
	| 	å 		\ % afnåhmen (by syllab.fst)
	| 	œ 

$SHORT_VOWEL_CLOSED$= \
	a \
	| e:ä \
	| Ä:ä \ % Kossät
	| e   \ % aben
	| i 	\ % anriggt
	| O:o 	\ % Auktschon, blos, Blothund
	| o 	\ % Botter
	| Ö:ö 	\ % Böm, glöw
	| ö 	\ % bröcht, dörch
	| œ 	\ % vœrbi (long vowel)
	| U:u 	\ % abslut, Antwurt
	| u 	\ % Anspelung
	| ü 	\ % besünn, darüm
	| Ü:ü 	\ % dürt, Dütschland

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% putting it all together %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. phonological rules\
% 3.a invalid phoneme patterns\
	!( .* (bb|dd|ff|gg|c|kk|kh|th|ll|mm|nn|pp|ph|q|rr|ss|tt|vv|ww|z|tv|sx| $V$ h) .* ) ||\
	\
% 2. author-specific rules \
% 2.a assimilation \
	($V$ | $C$ | $ASSIM$ | ['\-])* || \
% 2.b phoneme mapping \
	$CONS$* ($SHORT_VOWEL_OPEN$ | $SHORT_VOWEL_CLOSED$ $CONS$+ | $LONG_VOWEL$ $CONS$*)? \
	(['\-] $CONS$* ($SHORT_VOWEL_OPEN$ | $SHORT_VOWEL_CLOSED$ $CONS$+ | $LONG_VOWEL$ $CONS$*)?)*   || \
	\
% 1. generic preprocessing \
	"<syllab.a>" || \				% syllabify
	([a-zäöüæœå]:[A-ZÄÖÜÆŒÅ] | .)+ 	% lower casing

% could be further simplified by splitting consonants into coda and onset and handling syllabification together with phoneme mapping
% we could handle each consonant separately