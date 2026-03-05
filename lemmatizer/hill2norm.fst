%%%%%%%%%%%%%%%%%%%%
% output inventory %
%%%%%%%%%%%%%%%%%%%%

$C$=[bdfghjklmnprstvwxS]
$SEP$='
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu

%%%%%%%%%%%%%%%%%%%%
% overall alphabet %
%%%%%%%%%%%%%%%%%%%%

ALPHABET=['aäbcdefghijklmnoöpqrsßtuüvwxz\-] $C$ $V$ $SEP$ \_

%%%%%%%%%%%%%%%%
% author rules %
%%%%%%%%%%%%%%%%

$ASSIM$= \
	$V$ ' v:b $V$ % öaber

$CONS$= $C$ | \
	f:v | \
	k:{ck} | \
	k:c    | \ % Racaille
	{kw}:{qu} |\ % quoaden
	x:{ch} | \
	S:{sch} | \
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
	t (<>:[th])? | \
	{ts}:z  |\
	{ts}:{tz} |\
	v (<>:v)? | \
	w (<>:w)?

$LONG_VOWEL$=\
	å:{oa} (<>:h)? |\
	å (<>:h)? |\
	œ:{öa} (<>:h)? | \
	a:{aa} |\ % just an allophone of short /a/ before r
	Ä:{ää} |\
	Ä:{äh} |\	
	E:{ee} (<>:h>)? | \ % Veeh
	I:{ih} |\
	I:{ie} |\
	I:{ieh} |\	
	O:o (<>:[oh]) |\
	Ö:ö (<>:[öh]) | \
	U:u (<>:[uh]) |\
	Ü:ü (<>:[üh]) | \
	ei |\
	{au}:{au} |\ % hd.
	{äu}:{eu} | \
	{ei}:{ai} |\
	äu

$SHORT_VOWEL_OPEN$= \
	a:a | \ % nur in (hd) aber, haben; auch in lachen, aber das ist eigentlich keine offene silbe, kein beleg für å-Aussprache
	Ä:{ä}  |\
	e | \ % in unbetonten silben!
	E:e |\ % eben (hd?)
	I:i | \ % ilig
	i | \ % Krischoan
	U:u  |\
	O:o  |\
	Ö:ö  | \
	Ü:ü 

$SHORT_VOWEL_CLOSED$= \
	a |\
	e:ä | \
	Ä:ä |\
	e |\
	i |\
	o |\
	Ö:ö | \ %vergnöglich
	ö | \ % möckt
	u | \
	ü 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% putting it all together %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. phonological rules\
% 3.a invalid phoneme patterns\
%	!( .* (bb|dd|ff|gg|c|kk|kh|th|ll|mm|nn|pp|rr|ss|tt|vv|ww|z|sx| $V$ h) .* ) ||\
%	\
% 2. author-specific rules \
% 2.a assimilations and _ dropping \
	<>:\_ ($ASSIM$ | $C$ | $V$ | ['])* <>:\_ || \
% 2.b phoneme mapping \
	\_ ($CONS$ | $SHORT_VOWEL_OPEN$ ['\-] | $SHORT_VOWEL_CLOSED$ $CONS$ | $LONG_VOWEL$ | ['\_\-])+ \_? || \
% 2.c validate / postprocess syllable breaks \
%	!( .* ([oå]'[aå]|ä'ä|[oåä]'e|ö'[aå]|i'i|u'i) .* ) || \
%	\
% 1. generic preprocessing \
	\_:<> "<syllab.a>" \_:<> || \	% mark end and beginning, syllabify
	([a-zäöü]:[A-ZÄÖÜ] | .)+ 		% lower casing

