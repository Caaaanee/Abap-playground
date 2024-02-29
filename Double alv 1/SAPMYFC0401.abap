INCLUDE mzsk0410top                             .    " Global Data
INCLUDE mzsk0410class.
INCLUDE mzsk0410o01                             .  " PBO-Modules
INCLUDE mzsk0410i01                             .  " PAI-Modules
INCLUDE mzsk0410f01                             .  " FORM-Routines

LOAD-OF-PROGRAM.
  PERFORM set_default_cond CHANGING zsfc04100.
  "Set layout & ALV SORT
  PERFORM set_layo USING co_fix 'A' CHANGING gs_layo.
  PERFORM set_sort USING '1' 'BOOKID' co_fix.

perform test.