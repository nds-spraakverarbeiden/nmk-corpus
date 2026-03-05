$C$=[bdfghjklmnprstvwxS]
$SEP$=['+\-]
$V$=[aeiouöüAEIOUÖÄÜåœ] | au | ei | äu \
        | ou            % to be confirmed \
        | ä:e ä:a       % original a or e differently realized as either a or e, \
                                % e.g., _det_ (N.Mk.) "das" vs. _dat_ (C.Pm.) or _enner_ \
                                % "ander(er)" (N.Mk) vs. _anner_ (C.Pm.), but note that \
                                % these are very different regional processes
ALPHABET= $C$ $V$ $SEP$ [\ ] 

$DICTS$ = "<vocab_full.a>" \	% corpus-based
		| "<vocab.a>" \
		| "<prep.a>" \
		| "<part.a>" \
		| "<conj.a>" \
        | "roots.dic" \
        | "lexemes.dic" \
	  % | "<danneil.a>" {.altmk}:<> 	\ % more verbose 
        | "<danneil.a>"                 \ % less verbose

% lexical entries can be followed by grammatical information
$DICTS$ ((\. [A-Z0-9][a-zA-Z0-9\.\_]*) | (<>:\. <>:[a-z] (<>:[a-zA-Z0-9\.\_])*))*