% normalized input should have syllabification, but lemma DB does not
% we thus de-syllabify and remove double consonants
% note that we do not separate clitics

%%%%%%%%%%%%%%%%%%%%%
% phoneme inventory %
%%%%%%%%%%%%%%%%%%%%%

% consonants
$C$=[bdfghjklmnprstvwxS]
$V$=[aeiouöüEIOUÖÄÜåœ] | au | ei | äu | ou % ou is yet to be confimed

%ALPHABET=$C$ $V$ [\-']
% to be handled by the importing FST

%%%%%%%%%%%%%%%
% desyllabify %
%%%%%%%%%%%%%%%
% lemma matching requires clitic delimination and consonant simplification

$C=$ = $C$

$MAP$=\
	( [\-] | \
	 <>:' | \
	 b (<>:[b'])* | \
	 d (<>:[d'])* | \
	 f (<>:[f'])* | \
	 g (<>:[g'])* | \
	 h (<>:[h'])* | \
	 j (<>:[j'])* | \
	 k (<>:[k'])* | \
	 l (<>:[l'])* | \
	 m (<>:[m'])* | \
	 n (<>:[n'])* | \
	 p (<>:[p'])* | \
	 r (<>:[r'])* | \
	 s (<>:[s'])* | \
	 t (<>:[t'])* | \
	 v (<>:[v'])* | \
	 w (<>:[w'])* | \
	 x (<>:[x'])* | \
	 S (<>:[S'])* | \
	 $V$ )+

$INVALID_PATTERNS$= ' | bb | dd | ff | hh | jj | kk | ll | mm | nn | pp | rr | ss | tt | vv | ww | xx | SS

$DESYLLABIFY$ = (! (.* $INVALID_PATTERNS$ .*)) || $MAP$