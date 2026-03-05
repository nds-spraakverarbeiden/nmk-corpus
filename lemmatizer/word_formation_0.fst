#include "word_formation.fst"

$PRODUCTION$=\
   $VERB0$ | \
   $NOUN0$ | \
   $ADJ0$ | \
   $ADV0$ | \
   $NUM$ | \
   $AUX$ | \
   $PROPN$ | \
   ((($LEXEMES$|$ROOTS$) ([?]:<>)? || ([^+\-] | [+\-]:<> )*) || $ASSIMILATION$)

$DEBUG$= \
       $PRODUCTION$ || ...* /:<> ([a-zA-Z0-9_\.]:<>)*

% use this for debugging mode, esp. make test_word_formation
% $DEBUG$ | $PRODUCTION$

% use this for production mode, instead
$PRODUCTION$  (\. [A-Za-z0-9\_\.]+)* % || "<inflection.a>"
