% derived from born181x2norm.fst

%%%%%%%%%%%%%%%%%%%%
% output inventory %
%%%%%%%%%%%%%%%%%%%%

$C$=[bdfghjklmnprstvwxS]
$SEP$='
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu 
	% no evidence for ou

%%%%%%%%%%%%%%%%%%%%
% overall alphabet %
%%%%%%%%%%%%%%%%%%%%

ALPHABET=['aåäbcdefghijklmnoöpqrsßtuüvwxyz\-] \
	$C$ $V$ $SEP$  		% output symbols

%%%%%%%%%%%%%%%%
% author rules %
%%%%%%%%%%%%%%%%

$ASSIM$ = $V$ ' v:b $V$ % öäber \
		| s:{ts} 		% Zupperndent "Superintendent" \
		| E:œ r 		% öähr "ihre" \
		| i:ü r 		% Würthschaft \
		| a:e n $C$		% änner

$CONS$ = b (<>:b)?	\ % vöärbie
	   | x:{ch} 	\ % viellicht
	   | k:{ck} 	\ % sick
	   | S:{sch}	\ % schwoar
	   | k:c 		\ % Docter
	   | d (<>:d)?	\ % Voaderland, Eddelmann
	   | t:{dt}		\ % Stadt
	   | f (<>:f)?	\ % Wulf, köfft (auch: Wief)
	   | g (<>:g)?	\ % Tüg, fröggt
	   | h 			\ % häst
	   | j 			\ % jitzt
	   | k 			\ % riek
	   | l (<>:l)?  \ % woll
	   | m (<>:m)?	\ % üm, kümmt
	   | n (<>:n)? 	\ % wenn
	   | p (<>:p)?	\ % Kopp
	   | r (<>:r)? 	\ % würr
	   | s (<>:s)? 	\ % Voss, wusst
	   | t (<>:[th])?	\ % Moth, mütt
	   | f:v 		\ % vull (only v example is *German* November)
	   | w 			\ % würr'
	   | v:w 		\ % glöwen, glöwt, leew
	   | {ks}:x 	\ % nix
	   | (<>:t)? {ts}:z \ % jitzt

% note that the following operates on syllab output, not on plain text
$LONG_VOWEL$ = å:{aa} 	\ % Haar, Jaar
			 | å 		\ % syllab < noamen
			 % | a:{ah} 	\ % Jahre (hd)
			 | å (<>:h)?	\ % beståhn
			 | Ä:{äh}		\ % Tähne
			 | O:{oä} (<>:h)? \ % Oähr
			 | {ei}:{ai}	\ % Mai
			 | E:{ee} (<>:h)? \ % Peerd, Veeh
			 | E:{eh}  		\ % Rehn, Reh, nehmen
			 | ei (<>:h)? 	\ % steiht
			 | {äu}:{eu}	\ % freu'n
			 | I:{ie}		\ % Tiet
			 % | I:{ih}		\ % ihm (hd)
			 | å:{oa} (<>:h)?	\ % Woater, woahrt
			 | œ:{öä} (<>:h)?	\ % vöäruut, öähren
			 | œ 				\ % syllab < vöäruut, öähren
			 | O:{oh}			\ % Uprohr
			 | O:{oo}			\ % School, Oogen, Woort
			 | Ö:{öh}			\ % föhrt, Möh
			 | Ö:{öö}			\ % sööt, Wöör'
			 | {U'e}:{u'e}		\ % Fruens, Jue
			 | {Un}:{u'en}		\ % Juen (this is not an error, but hiat is treated differently)
			 | Ü:{üh}			\ % süht
			 | Ü:{üü}			\ % Lüüd
			 | U:{uu}			\ % Muus
			 % | U:{uh}			\ % (not attested)
			 \
			 \ % syllab + OCR errors 
			 | {Ohe}:{å'e}	\ % < Hohenzollern
			 
$SHORT_VOWEL_OPEN$ = a 			\ % kasproat
				   | Ä:ä 		\ % Wäder
				   | E:e 		\ % weren
				   | e 			\ % bedöhrt
				   | I:i 		\ % ji
				   | O:o 		\ % Broder % o:o not attested
				   | Ö:ö 		\ % nödig
				   | ö 			\ % Gröschen
				   | œ  		\ % < Wöhler
				   | U:u 		\ % Bu'r, du't, ju'n, Stuwe
				   | Ü:ü 		\ % Büdel, Düwel, Fü'r, Prüßen
				   % | y not attested

$SHORT_VOWEL_CLOSED$= a 		\ % Balbeer
					| e:ä 		\ % bäter
					| e 		\ % bäter
					| i 		\ % ick
					| I:i 		\ % Berlin
					| o 		\ % groff
					| O:o 		\ % Plog
					| ö 		\ % Börger, gröttre
					| Ö:ö 		\ % glöwt
					| u 		\ % dull
					% | U:u 	\ % not attested
					| ü 		\ % düchtig
					| Ü:ü 		\ % Krüz, Tüg
					| i:y 		\ % syn (sind, sein; Lautung unklar)

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
% 2.c syllab postfiltering
	(! .* (e'e) .*) || \
%	\
% 1. generic preprocessing \
	"<syllab.a>" || 					\ % syllabify
	( {Ji}:{Ii} |						\ % OCR errors
	([a-zäöüæœå]:[A-ZÄÖÜÆŒÅ] | . )+) 	\ % lower casing 

% could be further simplified by splitting consonants into coda and onset and handling syllabification together with phoneme mapping
% we could handle each consonant separately

