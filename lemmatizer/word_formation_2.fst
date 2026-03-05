#include "word_formation.fst"

$PRODUCTION$=\
  $NOUN2$ | \
  $ADJ2$ | \
  $ADV2$

$DEBUG$= \
       $PRODUCTION$ || ...* /:<> ([a-zA-Z0-9_\.]:<>)*

% use this for `make test_word_formation` 
% $DEBUG$ | $PRODUCTION$

% use this for production mode, instead
$PRODUCTION$  (\. [A-Za-z0-9\_\.]+)* % || "<inflection.a>"
