#include "word_formation.fst"

$PRODUCTION$=\
  $VERB1$ | \
  $NOUN1$ | \
  $ADJ1$
% why is there no $ADV1$ ???

$DEBUG$= \
       $PRODUCTION$ || ...* /:<> ([a-zA-Z0-9_\.]:<>)*

% use this for `make test_word_formation` 
% $DEBUG$ | $PRODUCTION$

% use this for production mode, instead
$PRODUCTION$  (\. [A-Za-z0-9\_\.]+)* % || "<inflection.a>"