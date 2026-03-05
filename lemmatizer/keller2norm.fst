%%%%%%%%%%%%%%%%%%%%
% output inventory %
%%%%%%%%%%%%%%%%%%%%
% derived from hill2norm.fst

$C$=[bdfghjklmnprstvwxS]
$SEP$='
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu

%%%%%%%%%%%%%%%%%%%%
% overall alphabet %
%%%%%%%%%%%%%%%%%%%%

ALPHABET=['aäbcdefghijklmnoöpqrsßtuüvwxyz\-] $C$ $V$ $SEP$ \_

%%%%%%%%%%%%%%%%
% author rules %
%%%%%%%%%%%%%%%%

$ASSIM$= \
	.	

$CONS$= $C$ | \
	k:c | \ % tuc
	x:{ch} | \
	S:{sch} | \
	b (<>:b)? | \
	d (<>:d)? | \
	f (<>:f)? | \
	g (<>:g)? | \
	h | \
	j | \
	k (<>:k)? | \
	l (<>:l)? | \
	m (<>:m)? | \
	n (<>:n)? | \
	p (<>:p)? | \ 
	{kw}:{qu} |\
	r (<>:r)? | \
	s (<>:s)? | \
	s:ß |\
	t (<>:[th])? | \
	{ts}:z  |\
	{ts}:{tz} |\
	f:v | \ % vull
	v (<>:v)? | \
	w (<>:w)?

$LONG_VOWEL$=\
	au | % Aust \
	U:{ou}	| % Coulisse \
	Ü:{üü} (<>:h)? | \
	Ü:{üh} 	| \
	äu 	(<>:h)? | % Fläuten \
	{äu}:{eu} (<>:h)? | % nur hd?\
	U:{uu} (<>:h)? | % Buur \
	U:{uh} 	| \
	au | % august \
	œ:{oe} (<>:h)? | % oewerst \
	Ö:{öö} (<>:h)? | % föhren \
	Ö:{öh} 			| % föhrten \
	O:{oo} (<>:h)? | % Woort \ 
	O:{oh} 			| % Batteljohn \
	I:{ie} (<>:h)? | % bestrieden \
	E:{ee} (<>:h)? | % wéeren \
	ei (<>:h)? | % Arbeit, beid \
	{ei}:{ai} (<>:h)? | % Waiten \
	å:{oa} (<>:h)?	| % Woagens, genoahm'n \
	{ei}:{a'i} (<>:h)?	| % Waiten \
	a:{ah}		| % wahr \
	å:a (<>:h)? | % stahn, Bråden \ \
	Ä:ä (<>:h)?	 % spräken, bäters, quälen, Stäwel, Maikäwers, Mäken, tämlich, säd, Pithähneken \

$SHORT_VOWEL_OPEN$= \
	Ü:ü 	| % Düwel, Hüser \
	U:u 	| % bruken, buten \
	Ö:ö 	| % glöwen, söten \
	œ:ö 	| % övel, överall \
	O:o 	| % grote, dato, Ogenblick \
	o  		| % Melodie, tosoam'n, Wochen, worüm, Oktober \
	I:i 	| % vivat, Stettiner, wi, vörbi \
	U:u 	| %  buten \
	E:e 	| % Ade, beden \
	e 		| % alle \
	Ä:e 	| % beten \
	å:a 	| % water, baben \
	a:a 	|  % waren, Vater \
	e:ä 	 % Wäsche, lächerlich \

$SHORT_VOWEL_CLOSED$= \
	Ü:ü | % Adjüs \
	ü | % darüm \
	U:u | % Brutmann \
	u 	| % drup, bug'n \
	œ:ö | % dörchut \
	Ö:ö | % französch, glöw, drög \
	ö 	| % Köster, dörch \
	o 	| % wollt \
	i 	| % Spinnrad \
	e 	| % better \
	a 	% versalg, backen

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% putting it all together %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. phonological rules\
% 3.a invalid phoneme patterns\
	!( .* (bb|dd|ff|gg|c|kk|kh|th|ll|mm|nn|pp|rr|ss|tt|vv|ww|z|sx| $V$ h) .* ) ||\
%	\
% 2. author-specific rules \
% 2.a assimilations and _ dropping \
	<>:\_ ($ASSIM$ | $C$ | $V$ | ['])* <>:\_ || \
% 2.b phoneme mapping \
  	\_ ($CONS$ | $SHORT_VOWEL_OPEN$ ['\-\_] | $SHORT_VOWEL_CLOSED$ $CONS$ | $LONG_VOWEL$ | ['\_\-])+ || \
% 2.c validate / postprocess syllable breaks \
	!( .* ([oå]'[aå]|ä'ä|[oåä]'e|ö'[aå]|i'i|i'e|ck) .* ) || \
%	\
% 1. generic preprocessing \
	\_:<> "<syllab.a>" \_:<> || \	% mark end and beginning, syllabify
	([a-zäöü]:[A-ZÄÖÜ] | .)+ 		% lower casing

