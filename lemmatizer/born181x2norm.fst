% minor adjustments from Bornemann 1868, only

%%%%%%%%%%%%%%%%%%%%
% output inventory %
%%%%%%%%%%%%%%%%%%%%

$C$=[bdfghjklmnprstvwxS]
$SEP$='
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu | ou % bei ou ist zu prüfen, inwieweit das von au unterschieden werden kann

%%%%%%%%%%%%%%%%%%%%
% overall alphabet %
%%%%%%%%%%%%%%%%%%%%

ALPHABET=['aåäbcdefghijklmnoöpqrsßtuüvwxyz\-] \
	$C$ $V$ $SEP$  		% output symbols

%%%%%%%%%%%%%%%%
% author rules %
%%%%%%%%%%%%%%%%

% Bornemann 1868
$ASSIM$ = $V$ ' v:b $V$ % Noaber, öber \
	    | r s:S t 	    % Worscht (this is a Central German trait, Low German should have lost the r before, this might be a full loan word, not a regular process) \
	    | a:e n [']? $C$ 	% änners

% Bornemann 1868, with minor addenda
$CONS$= $C$ \
	| b (<>:b)? 	\ % herby, hebb'
	| S:{sch}		\ % Gröschen, schloan
	| k:c 			\ % Casper, Respect (Bornemann 181x)
	% | {ts}:c 		\ % Recensenten (Bornemann 181x, but this is Standard German)
	| x:{ch}		\ % dörch, Hochtied
	| k:{ck}		\ % sprach, sick
	| d:{dt}		\ % Schmedt (auslautverhärtung)
	| d (<>:d)?		\ % bedd
	| f (<>:f)?		\ % Groffschmedt
	| g (<>:g)? 	\ % segg, twintig
	| h 			\ % holl'n, ümher (not postvocalic, not after t or c)
	| t (<>:h)?		\ % Noth, werth
	% | j 			\ % Joahr (covered by $C$)
	% | k 			\ % Schlunk, Beerschenk (-"-)
	| l (<>:l)?		\ % holl
	| m (<>:m)?		\ % tosamm
	| n (<>:n)?		\ % wenn
	| p (<>:p)?		\ % Kopp
	| r (<>:r)? 	\ % werr'n
	| s (<>:s)?		\ % Voss
	| s:ß 			\ % vörbaß
	| t (<>:t)?		\ % sitt
	| v 			\ % broave, Pulver
	| f:v 			\ % doavon
	| v:w 			\ % Düwel, leewe
	| w 			\ % wat, vörwärts
	| {ks}:x 		\ % Blix, fix
	| (<>:t)? {ts}:z \ % Danz, jitzt 

% extend Bornemann 1868 with (<>:h)?
% note that the following operates on syllab output, not on plain text
$LONG_VOWEL$= {ei}:{ay} (<>:h)? \ % Mayen-König (hd)
			| {ei}:{ai}	(<>:h)? \ % Kaiser, Maid (hd)
			| å:{oa} (<>:h)?	\ % poar, noah
			| å 		\ % Hågel
			| Ä:{äh}	\ % däh, Tähn, ungefähr
			| E:{ee} (<>:h)?	\ % twee, weer, Schnee
			| E:{eh}	\ % vörnehme
			| I:{ie} (<>:h)?	\ % Hochtied
			| œ:{öä} (<>:h)?	\ % Döär, höären
			| O:{oo} (<>:h)?	\ % Schooljungs, Woort, doon
			| O:{oh}	\ % Ohr, Suerkohl, froh, doh, Koh, Stroh; folgende könnten auch å sein: dohn (falls "getan"), Hohn (falls "Hahn")
			| Ö:{öö} (<>:h)?	\ % föör'n, föört, Köö
			| Ö:{öh}	\ % föhrt, fröh
			| U:{uu} (<>:h)?	\ % Buur, kuum, suur
			| U:{uh}	\ % Uhlenspeegel
			| Ü:{üü} (<>:h)?	\ % süüt
			| Ü:{üh}	\ % süht
			| au (<>:h)?	\ % Paul
			| {ou}:{ow}	\ % Gneisenow
			| ei (<>:h)?	\ % klein, Eikboom, Meister, tein, beide, deit; kreiht (Bornemann 181x)
			| {ei}:{ey}	(<>:h)?		\ % Hey! Juchhey!
			| {ei}:{e'y} (<>:h)?	\ % < Hey! Juchhey!
			| I:y 	(<>:h)?	\ % wyn
			\
			% syllab artefakte: \
			| å:{å'a} (<>:h)?	\	   % < doan
			| {ei'e}:{a'y'e} \ % < Mayen-König (hd)
			| {ei'e}:{ay'e}	 \ % < -"-
			| {Er}:{ee'a}	 \ % < regeert?
			| {e'hÖ}:{ee'ö}	 \ % < gehört
			| å:{o'a} (<>:h)?		 \ % < Spoaß
			| å:{o'å} (<>:h)?		 \ % < afgedoahn
			| œ:{ö'ä} (<>:h)?		 \ % < höären
			| U:{u'e}	  	 \ % < Suerkohl
			| Ö:œ (<>:h)?			 \ % < föhrn (not /œ/ !)

% = Bornemann 1868
$SHORT_VOWEL_OPEN$= a \
				  | Ä:ä % äre, Jäger, Mäkens, Näse, spräken \
				  | E:e % Segen, Peter, ene, kene \
				  | e   % r_e_geer'n, Könegin \
				  | i   % Bischop, Krischoan \
				  | O:o % Ogenblick \
				  | o   % toletzt \
				  | œ:ö % öberst, söben \
				  | Ö:ö % hören \
				  | ö   % Gröschen \
				  | U:u % brunen, dusend \
				  | Ü:ü % Düwel

% = Bornemann 1868
$SHORT_VOWEL_CLOSED$= a 	% wat \
					| e:ä 	% häst, män \
					| Ä:ä 	% väl \
					| e 	% Botter \
					| E:e 	% kreg ? (Ä?)\
					| i 	% wuchtig \
					| I:i 	% sin, Berlin \
					| o  	% Bischop \
					| O:o 	% Not, Moth \
					| œ:ö 	% vörnehm \
					| ö 	% Görgel\
					| Ö:ö 	% hört \
					| U:u 	% ut \
					| u 	% wußt\
					| Ü:ü 	% Tüg \
					| ü 	% ümher, ümsünst \
					| i:y 	% Tyll (mnd.? sonst immer lang)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% putting it all together %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. phonological rules\
% 3.a invalid phoneme patterns\
	!( .* (bb|dd|dt|ff|gg|gk|c|kk|kh|th|ll|mm|nn|pp|ph|q|rr|ss|tt|vv|ww|z|tv|sx| $V$ h | [oOåa]'[åa] ) .* ) ||\
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
	([a-zäöüæœå]:[A-ZÄÖÜÆŒÅ] | . | ä:{åͤ} )+ 	% lower casing, some OCR postprocessing ; Bornemann 181x: added ä:{åͤ}

% could be further simplified by splitting consonants into coda and onset and handling syllabification together with phoneme mapping
% we could handle each consonant separately

