ALPHABET=[a-zöäü'\-œæå'ß]

% syllabification
% we can process every word that occurs at least 10 times in the corpus
% tested with
% 	if fst-compiler-utf8 syllab.fst syllab.a; then cut -f 1 ../upos/*.conll | grep -v '#' | egrep . | egrep '[a-zA-ZöäüßÖÄÜœæåŒÆÅ]+$' | sed s/'.*'/'\L&'/g | sort | uniq -c | egrep '[0-9][0-9]' | sed s/'^[ 0-9\t]*'// | fst-infl syllab.a ; fi | grep 'o res' | sed s/'.* '//g | less

$V$=[aeiouöäüyœ]|au|ei|ee|ie|oo|uu|oe|äu|öä|öa|aa|ay|ey|oa|ai|å|y\
	\ % OCR errors: 
	| œ:æ   \ % Dörr, overall
	| œ:ø 	\ % occasional
	| a:{á} \ % dát with spot
	| a:{á} \
	| ä:{á} \ % dát for dät?
	| ä:{á} \
	| a:{à} \ % am with spot
	| a:{à} \
	| ä:{à} \ % äm (em) ?
	| ä:{à} \
	| a:{â} \ % dât
	| a:{â} \
	| ä:{â} \ % dât
	| ä:{â} \
	| å:{â} \ % prinzipiell möglich, nicht in unseren texten
	| å:{â} \
	| {oo}:ô \ % dôp
	| ö:ô \
	| o:ô % OCR error \
	| ü:{ů} \
	| ü:{üͤ} \
	| ü:{ú} \ 
	| {ö}:{oͤ} \ % moͤrderlich; NOTE: accent not shown in sublime :( 
	| {ä}:{åͤ} \  % håͤt, should be hät
	%| {j}:i   \ % frequent OCR error
	\
	\ % length marking
	|{uu}:{ue} % Buern \
	|{üü}:{üe} % Füersbrunst \
	| üü       % düütsche (Jung) \
	|{uu}:{u'} % Bu'rn \
	| uu       % Königshuus (Jung) \
	|{üü}:{ü'} % analogy with Bu'rn \
	|{ee}:{eh} % afnehmen \
	|{uu}:{uh} \
	|{aa}:{ah} \
	|{å}:{ah} \
	|{oo}:{oh} \
	|{å}:{oh} \
	|{öö}:{öh} \
	|{œ}:{öh} \
	|{üü}:{üh} \
	\
	\ % additions for Hill
	| å:{oa} \ 
	| Ä:{Ae} \
	| ä:{ae} \
	| eu \
	| ai \
	| öö \
	\
	\ % additions for Bornemann 181x
	| {ei'e}:{eie} \	% Eier
	| {ie'e}:{iee} \ 	% niee (nieje)
	\
	\ % additions for Keller
	| {ai'e}:{aie} \ 	% baiersch
	| {ei'e}:{eie} \	% beiern
	| {eu}:{oi}	   \ 	% Boira
	| ou 		   \	% Courosch
	| i n:u t 	   \ 	% Hiutergrunde (hd, ocr)
	| ü:{ii}	   \ 	% iimmer (ocr)
	| u ':<> i 	   \	% Luiken (dim. von Luis)
	\
	\ % for Schwerin
	| œ:{oå}		\ 	% voål, OCR-fehler für voäl
	| å:{oa}		\	% spoarnstrieks

$C$=[bcdfghjklmnpqrstvwxzß] \
	| t <>:h % Besitzthum \
	| t:{dt} % aerndte \
	| s:{ß} % Perßon \
	| sch   % baiersch


% wir machen's freihändig, ' zeigt silbengrenzen, klitisierung und überlänge an

$BREAK$= 	\
	  	b ':<> [dtbpgks] [rl]? \ % absluut
	 |  b ':<> s [tp] \ % absteigen (hd)
	 | 	b ':<> [hjnszw]  \ 
	 |  b ':<> ch \ % Liebchen (hd)
	 |  bl ':<> $C$+ \ % Böblken
	 | 	':<> [bpdtkgf][r]? \
	 | 	':<> [bpkgf][l]? \
	 | 	':<> [dtk][w]? \
	 |  ':<> sn 	\ % Gesnoater (Schwerin)
	 | 	b ':<> sch [lmnrw]? \ % abschneidet (hd)
	 |  b ':<> l ':<> k \ % Böblken \
	 | 	':<> ch \
	 |  ':<> c % Joacob \
	 | 	ch ':<> [dt][r]? \
	 |  ch ':<> [gpbf][rl]? \
	 |  ch ':<> [k][rlw]? \
	 |  ch ':<> [z][w]? \
	 |  ch ':<> s[tp][rl]? \
	 |  ch ':<> sch [lnmwr]? \
	 |  ch ':<> [hlmnrsw] \ % Nachricht (hd)
	 | 	ch ':<> s[pt][r]? \ % hochstudeerte
	 | 	chs ':<> $C$+ \ % Reichstag
	 | 	cht ':<> [gktdf][rl]? \ % uprichtger
	 | 	cht ':<> [lmz] \		% achtzig (hd) 
	 | 	cht ':<> sch  $C$*\
	 | 	cht ':<> str  $C$* \ % Lichtstriepen
	 | 	chts ':<>  $C$* \ % Rechtsanwalt
	 | 	k:{ck} ':<>  $C$* \
	 | k:{ck} s ':<> k  $C$* \
	 | c ':<> t  $C$*\
	 | ':<> cl \ % declamirend (hd)
	 |  ':<> d \
	 | d ':<> [bdtvwk] $C$* \ % Broodbüdel, Rädken
	 | d ':<> [jlnmrg]  $C$*\
	 | d ':<> ch 	\ % Mädchen (hd)
	 | d ':<> t  $C$*\
	 | d ':<> [sh] \ % Blödsinn (hd), Drüdhalw
	 | ds ':<> [kt]  $C$*\
	 | dt ':<> [mf]  $C$*\
	 | dts ':<> k $C$* \
	 |  ':<> f \
	 | [rnl]*f+ ':<> [bdgkpz] $C$* \
	 | [rnl]*f+ ':<> s \
	 | [rnl]*f+ ':<> s? [tp] [rwl]? \
	 | [rnl]*f+ ':<> [mrln] \
	 | [rnl]*f+ ':<> [fhlmnw] \
	 | [rnl]*f+ ':<> sch $C$* \
	 |  ':<> fr \
	 | [rnl]*fs ':<> str $C$* \
	 | [rnl]*ft ':<> [bgstm] $C$* \ % Luftballon (hd)
	 | [rnl]*fts ':<> g $C$*\
	 |  ':<> g \
	 | g+ ':<> [bdfghlmnkrstw] $C$*\
	 | g+ ':<> sch $C$*\
	 | gd ':<> g $C$*\
	 |  ':<> gr \ % gegrämt, BUT: moagrer
	 | gs ':<> [bgmptw] $C$* \
	 | gs ':<> [hk] \ % Königshuus, Kriegskosten (hd)
	 | gs? ':<> st [r]? \ % Königsstroat
	 | ':<> h \
	 | h ':<> [bdfg] $C$*\
	 | hg ':<> t $C$*\
	 | h ':<> [hjlnmrs] \
	 | h ':<> k [lnrws]? \
	 | hl ':<> t \
	 | hm ':<> [klt] $C$* \
	 | hms ':<> d $C$* \
	 | hn ':<> [bhklst] $C$* \
	 | hr ':<> [bfghlmntw] $C$* \
	 | hr ':<> sch $C$* \
	 | h ':<> [stw] $C$* \
	 |  ':<> j \
	 |  ':<> k \
	 | k ':<> [bdfghklnrtw] $C$* \
	 |  ':<> kl \ %bekloagen, BUT: spikleerten, rieklich
	 | k ':<> sch $C$* \
	 | ks ':<> t $C$* % klöksten \
	 | k ':<> st $C$* % Bokstaben \
	 | k ':<> s % Büksen \
	 | kt ':<> sch \
	 |  ':<> l \
	 | l+ ':<> [hjlmnrvw] \
	 | l+ ':<> sch [lmnrw]? \
	 | l+ ':<> s ([pt] r?)? \
	 | l+ ':<> [bdfgkptw] r? \
	 | l+ ':<> [bdfgkp] l? \
	 | l+ ':<> [dktz] w? \
	 | l+ ':<> [gk] n? \
	 | l ':<> ch $C$* \
	 | lb ':<> kr \ % Halbkreis (hd)
	 | lbst ':<> v $C$* \
	 | ld ':<> [bpklmntvw] $C$* \
	 | ld ':<> sch $C$* \
	 | lf ':<> [jlrw] $C$* \ % haldlud
	 | lg ':<> t $C$*\
	 | lk ':<> [gm] $C$* \
	 | l ':<> kn \
	 | lms ':<> t \ 	% Schwerin: sülmsten
	 | lp ':<> [lr] $C$*\ % hülplos, hülpriek, BUT Rüpelplick, Noagelprobe \
	 | l+ ':<> sch [lmn]* \
	 | lsch ':<> t $C$* \
	 | ls ':<> [dt][r]? \ % Döwelsdreck
	 | ls ':<> [tw] \ % Pulster, BUT Schoolstunn
	 | lt ':<> [gknsw] $C$* \
	 | lt ':<> sch $C$* \
	 | lw ':<> g $C$* \ % sülwgen 
	 | lws ':<> t $C$* \ %sülwsten 
	 |  ':<> m \
	 | m+ ':<> [bp] [rl]* \ % Lamperts-
	 | m+ ':<> ch \ % Lämmchen (hd)
	 | m+ ':<> [dfghklmnrstp] \
	 | mm ':<> st $C$* \
	 | mp ':<> [fkltw] $C$* \
	 | m+ ':<> pl % Komplott, BUT Hämpling \
	 | m+ ':<> s[pt] $C$* \
	 | ms ':<> s[pt] $C$* \
	 | ms  ':<> t $C$* \
	 | mt ':<> $C$* \
	 |  ':<> n \
	 | n ':<> [bcdf] $C$* \
	 | nch ':<> [hm] $C$*\
	 | nd ':<> [bfghklmwz] $C$* \
	 | nd ':<> sch $C$* \ % Landschafts-
	 | nds ':<> [fklmt] $C$* \
	 | nd ':<> [st] $C$* \
	 | ndt ':<> sch $C$* \
	 | nf ':<> [htz] $C$*\
	 | nft ':<> g $C$*\
	 | ng ':<> [bfhjklnrstw] % anhänglich, Jungfer (hd) \
	 | n+ ':<> g[lr]? % unglöwlich \
	 | ng ':<> sch $C$* \
	 | ng ':<> g \ % Schwerin: Singgeschlechts (sic!)
	 | n+ ':<> h \
	 | ngs ':<> [lh] \ % besinnungslos, Sperlingshoahn
	 | ngs ':<> t $C$*\
	 | ngst ':<> l \
	 | ngst ':<> sch[lnmw]? \
	 | nk ':<> [bhl] \
	 | n+ ':<> k[lnr]? % Dänenkriege, Lampenknecht, unklok, BUT kränklich \
	 | nk ':<> [rtm] $C$* % Frankriek, Denkmoal \
	 | n+ ':<> [lmndkrtw] \
	 | n+ ':<> sch [mnlwr]? \
	 | n+s[t]? ':<> [lvh] \ % einstweilen (hd), Sperlingshoahn
	 | n+s? ':<> sch [lmnw] \ % Koopmannsschaft
	 | n+t ':<> [mnw] \
	 | n+ ':<> $C$ \
	 | n+ ':<> k [wlrn]? \
	 | n+ ':<> [bpdtf][r]? \
	 | n+ ':<> [bpf][l]? \
	 | n+ ':<> s[pt][rl]? \
	 | nsch ':<> [hlpt] \
	 | n+ ':<> sch[lmnw] \ % Klockenschlag, BUT minschlich
	 | ns ':<> [gdklmnr] \ % unsrer
	 | ns ':<> gr \ % Herzensgrund
	 | n+ ':<> s[pt][rl]? \
	 | nst ':<> st $C$* \
	 | ns ':<> w \
	 | nt ':<> [ghjlnw] \
	 | n+ ':<> tr \ % Kuntract, intreden
	 | n+t ':<> (s | z [w]?) \
	 | n+t ':<> sch [lmnw]* \
	 | n+t ':<> st [rl]*\
	 | n+t ':<> w $C$* \
	 | n+ ':<> [vwz] \
	 | n ':<> zw 	\ % inzwischen (hd)	 
	 | nz ':<> [glmt] \
	 |  ':<> p[rl]? \
	 | p+ ':<> [bdfgkt] [rl]? \
	 | p+ ':<> [zk] [w]? \
	 | p+ ':<> [hlmnprsw] \
	 | p+ ':<> sch [lmnw]?\
	 | p+ ':<> s[pt] [rl]? \
	 | ps ':<> [k] [lnw]? \
	 | p+ ':<> th \
	 | pt ':<> [wms] \	% Hauptmann, Hauptsach (hd)
	 | pt ':<> s[tp] \	% Hauptstück (hd)
	 | pt ':<> k [w]? \	% Hauptquarteer
	 |  ':<> q \
	 |  ':<> r \
	 | r+ ':<> [bd][lr]? \
	 | r+ ':<> ch \
	 | rb ':<> b \
	 | rbs ':<> t \ % Herbstes-Nacht (hd)
	 | rch ':<> [ghwbz] \ % dörchbohrt, durchzuführen (hd)
	 | rch ':<> k[rl]? \
	 | rch ':<> [tb][r]? \ % dörchbreken
	 | rch ':<> sch [lrmn]? \ % dörchschloahn
	 | rcht ':<> b \
	 | rd ':<> ([nbp] | pf) \ % Erdboden, Erdpfoahl
	 | r+ ':<> [f][lr]? \
	 | rf ':<> t[rw]? \
	 | r+ ':<> g[lr]? \
	 | rg ':<> [mnr] \
	 | rg ':<> sch \
	 | rg ':<> [dt][rl]? \
	 | r+ ':<> [hj] \
	 | r+ ':<> [k][nrl]? \
	 | rk  ':<> [lh] \
	 | rk ':<> sch [lmnw]? \
	 | rks ':<> [tb] \ % Stärkste, Handwerksbuss
	 | rk ':<> st[r]? \ % Werkstück
	 | rk ':<> [tw] \
	 | rls ':<> $C$ \ % Karlsruh
	 | r ':<> [ml] \ % allermeist, Sperlingshoahn
	 | r+ ':<> [lm] \
	 | rm ':<> [hl] \
	 | rm ':<> [bdt][lr]? \
	 | r[mn]s ':<> t[l]? \ % armste, ärnstlich
	 | r+ ':<> [qn] \
	 | rn ':<> [bdtgkhs][lr]? \ % Elternhaus (hd), Kernsaldoaten
	 | rnd ':<> l \
	 | rn ':<> st[r]? \	% Schwerin: spoarnstrieks
	 | rnst ':<> h \
	 | r+ ':<> p[lr]? \
	 | rp ':<> sch[nmlw]? \
	 | rp ':<> s[pt][rl]? \
	 | rp ':<> w \ % Dörpwach
	 | r+ ':<> kw \
	 | r+ ':<> [rjlmst] \
	 | r+ ':<> [dgt][lrw]? \
	 | r+ ':<> [k][lrwn]? \
	 | r+ ':<> sch \
	 | r+ ':<> s \
	 | r+ ':<> sch[lmnrw]? \
	 | rs(ch)?t ':<> [sl] \ % Worschtsupp, erstlich
	 | rs ':<> [dlmn] \ % Geiersdörp
	 | r+ ':<> s[pt][r]? \
	 | r+ ':<> s:{ß} \ % Perßon
	 | rß ':<> \
	 | rs ':<> t \
	 | r+ ':<> t[rlw]? \
	 | rt ':<> h \
	 | rt <>:h ':<> [dflnrw] \
	 | rt <>:h ':<> sch[nmlrw]? \
	 | rt <>:h ':<> [dtbpkg][lrw]? \
	 | rts ':<> d \
	 | r+[z]? ':<> f:v \
	 | r+ ':<> w [rl]? \
	 | r+ ':<> z [w]? \
	 | rz ':<> [hlm] \
	 |  ':<> s \
	 | s+ ':<> s[tp][r]? \
	 | s+ ':<> [bdtpgkf][r]? \
	 | s+ ':<> [bpgkf][l]? \
	 | s+ ':<> [gk][n]? \
	 | s+ ':<> [k][w]? \
	 |  ':<> sch \
	 | sch ':<> [bfdtkg] $C$* \ % Flüschken, Dischgebet
	 |  ':<> sch[lmnrw]? \
	 |  ':<> schw \
	 | s+ ':<> [hlm] \
	 | ':<> sp \
	 |  ':<> spr \
	 | s+ ':<> r \
	 | s+ ':<> s \
	 |  ':<> s:ß \
	 | s+ ':<> sch[lrwnm]? \
	 | s+ ':<> d[rl]? \
	 | ß ':<> [bpkgdtf][rl]? \
	 | s+ ':<> h \
	 | ß ':<> $C$* \
	 | s+ 	 ':<> l \
	 | s+ ':<> [bpdtkg][lr]? \
	 | st ':<> [bdfgklt][rl]? \ % Oestreich
	 | st ':<> [hlmrswz] \ % Festzug (hd)
	 | st ':<> s[pt][r]? \
	 |  ':<> s[pt][r]? \ % gestroakt
	 | s ':<> tr \ % Magestroat
	 | s+ ':<> [wz] \
	 |  ':<> t \
	 | [rln]?t+ ':<> [bpdtgk][rlw]? \
	 | [rln]?t ':<> t \ % antwurtte
	 | [rln]?t+ ':<> ch \
	 | [rln]?t+ ':<> [f][lr]? \
	 | [rln]?t+ ':<> h \
	 | [rln]?t <>:h [s]? ':<> [hl] \
	 | [rln]?t <>:h ':<> r \
	 | [rln]?t (<>:h)? ':<> [sß][pw] \ % Rothßwanz
	 | [rln]?t <>:h ':<> w \
	 | [rln]?t+ ':<> k[rln]? \
	 | [rln]?t+ ':<> [lmn] \
	 | [rln]?t+ ':<> [bpdt][r]? \
	 |  ':<> tr \ % getrüe
	 | [rln]?t  ':<> r \ %bätre
	 | [rln]?t+ ':<> s \
	 | [rln]?t+ ':<> sch[lmnwr]? \
	 | [rln]?tsch ':<> [tp][rw]? \ % Kutschpeer
	 | [rln]?t+ ':<> s[pt][r]? \
	 | [rln]?t+ ':<> [dtbpfkg][r]? \
	 | [rln]?t+ ':<> ch \
	 | [rln]?t+ ':<> g[rl]? \
	 | [rln]?t+ ':<> [hlm] \
	 | [rln]?t+ ':<> [tpdb][rl]? \
	 | [rln]?t+ ':<> sch[lmnwr]? \
	 | [rln]?t+ ':<> s[tp][r]? \
	 | [rln]?t+ ':<> w \
	 | [rln]?t+ ':<> f:v \
	 | [rln]?t ':<> w \
	 | [rln]?t ':<> z \
	 | [rln]?t?z ':<> [bdgktf]	[rlw]? \ % Schanzkörw, Kratzfoot
	 | [rln]?t?z ':<> [lmn] \
	 | [rln]?t?z ':<> sch [nlm] \ % blitzschnell (hd)
	 |  ':<> f:v \
	 |  ':<> [wv] \
	 | v ':<> [vt] \ % duvvelt, leevte
	 | vs ':<> 	\ % Leevserklärung
	 | w ':<> [dktbpg][rl]? \
	 | w ':<> [hlnw] \ % hewwen
	 | w ':<> sch[lmnwr]? \
	 | w ':<> s[tp][r]? \
	 | {k's}:x \
	 | {ks}:x ':<> [bpgkdtfwz][rlw]? \ % inexzeert
	 |  ':<> z [w]?\ % bezwingen (hd)
	 | z ':<> [rt] \
	 | $C$* ' $C$* \
	 | ':<> % hiat insertion: TODO: should be limited to cases with non-identical vowels ... but we don't see vowels out of $BREAK$

$SYLLABIFY_ONE_WORD$= ( $C$* | ['] )* ($V$ ( $BREAK$  $V$)* (['] | $C$)*)? 

$SYLLABIFY$=$SYLLABIFY_ONE_WORD$ ( [-] $SYLLABIFY_ONE_WORD$)*

$SEP_SAME_VOWEL$= \
	a ' [ae] | \
	[^i] e ' e | \	% Bornemann 181x: niee
	[^e] i ' e | \ 	% Eier !
	o ' o | \
	o ' å | \
	u ' u | \
	ö ' ö | \
	ü ' ü | \
	å ' å | \
	å ' o | \
	å ' a | \
	å ' ä | \
	å ' i | \
	ee' a | \
	ee' o | \
	ee' ö | \
	ee'oa | \
	ee'å  | \
	i'i | \
	oa'ä | \
	oo'e |\
	% u'a |\ Januar !
	% o'ä |\ Oähr!
	oo'i |\
	' e ' | \
	% ' i ' | \ Luiken (Keller)
	' a ' | \
	' o ' | \
	' ö ' | \
	' u ' | \
	' ü ' | \
	œ ' œ | \
	æ ' æ | \
	o ' a | \
	ö ' a | \
	ö ' ä | \
	ä ' u | \
	ä ' ä | \
	a ' u | \
	e ' i | \
	[^e]e ' u | \ % accept tweeuntwintig (Dörr)
	e ' y | \
	% a ' i | \ % Keller: baiersch
	A ' [ae] | 	E ' e | 	Ä ' ä | I ' e | 	O ' o | 	U ' u | 	Ö ' ö | 	Ü ' ü | 	Å ' å | 	Œ ' œ | 	Æ ' æ | 	O ' a | 	Ö ' a | 	Ä ' u | 	A ' u | 	E ' i | 	E ' u | 	E ' y | 	A ' i | \
	o ' o % Koopmannsschaft

$VALIDATOR$=\
	!( .* $SEP_SAME_VOWEL$ .*) \
	|| ($C$ | ['])* ($V$ ( $C$* ['\-]+ $C$* $V$)* ($C$ | ['])*)? 

$VALIDATOR$ || \
$SYLLABIFY$ || \
[a-pr-zöäüßœåæ\-']* || \
([a-zöäüœæ]:[A-ZÖÄÜŒÆ]|{å}:{Å}|ä:{äͤ}|å:{å}|k:c [^h]|{kw}:{qu}|{kw}:{Qu}|{ss}:ß|s:ß|r:{ř}|e:{é}|t:{th}|{ai}:{ay}|i:y|$C$|$V$|.)* 


