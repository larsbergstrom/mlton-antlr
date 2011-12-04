/* ______________________________________________________________________
   MLPlay0.g

   Core SML98 grammar without any package stuff.  Adapted from
   Definition of Standard ML (Revised).

   Jonathan Riehl
   ______________________________________________________________________ */

grammar MLPlay0;

start: program;

program
    : exp ';' program?
    ;

scon
    : INT
    | FLOAT
    | STRING
    | CHAR
    | WORD
    ;

vid
    : ID
    | SYMBOL_ID
    | '*'
    ;

// ____________________________________________________________________________
// Patterns

atpat
    : '_'
    | scon
    | 'op'? vid // XXX
    | '{' patrow '}'
    | '(' (pat (',' pat)*)? ')'
    | '[' (pat (',' pat)*)? ']'
    ;

patrow
    : '...'
    | ID '=' pat (',' patrow)?
    | vid (':' ty)? ('as' pat)? (',' patrow)?
    ;

pat
    : pat1 ('as' pat1)?
    ;

pat1
    : pat2 (':' ty)?
    ;

pat2
    : atpat atpat*
    ;

// ____________________________________________________________________________
// Types

ty  : ty1 ('->' ty1)*
    ;

ty1 : ty2 ('*' ty2)*
    ;

ty2 : ty3 ID?
    ;

ty3 : TYVAR
    | '{' tyrow? '}'
    | ID
    | '(' ty ')'
    ;

tyrow
    : ID ':' ty (',' tyrow)?
    ;

tyvarseq 
    : TYVAR
    | /* empty */
    | '(' TYVAR (',' TYVAR)* ')'
    ;

// ____________________________________________________________________________
// Declarations

valbind
    : pat '=' exp ('and' valbind)?
    | 'rec' valbind
    ;

fvalbind
    : fvalbind1 ('|' fvalbind1)* ('and' fvalbind)?
    ;

fvalbind1
    : 'op'? vid atpat+ (':' ty)? '=' exp
    ;

typbind
    : tyvarseq ID '=' ty ('and' typbind)?
    ;

datbind
    : tyvarseq ID '=' conbind ('and' datbind)?
    ;

conbind
    : 'op'? vid ('of' ty)? ('|' conbind)?
    ;

exbind
    : 'op'? vid ('of' ty)? ('and' exbind)?
    | 'op'? vid '=' 'op'? ID ('and' exbind)?
    ;

dec 
    : /* Empty */
    | dec1 (';'? dec1)*
    ;

dec1
    : 'val' tyvarseq valbind
    | 'fun' tyvarseq fvalbind
    | 'type' typbind
    | 'datatype' datbind ('withtype' typbind)?
    | 'datatype' ID '=' 'datatype' ID
    | 'abstype' datbind ('withtype' typbind)? 'with' dec 'end'
    | 'exception' exbind
    | 'local' dec 'in' dec 'end'
    //| 'open' (ID ('.' ID)*)+
    | 'infix' INT? vid+
    | 'infixr' INT? vid+
    | 'nonfix' vid+
    ;

// ____________________________________________________________________________
// Expressions

atexp
    : 'op'? vid
    | scon
    | '{' exprow? '}'
    | '#' ID
    | '(' (exp (',' exp)*)? ')'
    | '[' (exp (',' exp)*)? ']'
    | 'let' dec 'in' exp (';' exp)* 'end'
    ;

exprow
    : ID '=' exp (',' exprow)?
    ;

appexp
    : atexp+
    ;

exp
    : 'if' exp 'then' exp 'else' exp
    | 'while' exp 'do' exp
    | 'case' exp 'of' match
    | 'fn' match
    | 'raise' exp
    | exp1
    ;

exp1
    : appexp ( ':' ty
             | ('andalso' | 'orelse') exp
             | 'handle' match
             )?
    ;

// NOTE: There is a known issue in ANTLR 3 that causes the next production to
// generate a warning, but where the greedy setting below should suppress the
// warning, but doesn't.

match
    : mrule ((options {greedy=true;} : '|') mrule)*
    ;
    
mrule
    : pat '=>' exp
    ;

// ____________________________________________________________________________
// Lexical stuff

TYVAR : '\'' IDCHAR+;

ID
    : ('a'..'z'|'A'..'Z') IDCHAR*
    | '_' IDCHAR+
    ;

SYMBOL_ID
    : '-' (SYMBOL_NOGT SYMBOL* | '>' SYMBOL+)?
    | '=' (SYMBOL_NOGT SYMBOL* | '>' SYMBOL+)?
    | LONE_SYMBOL SYMBOL*
    | ('#' | ':' | '~' | '|') SYMBOL+
    ;

fragment
IDCHAR
    : ('a'..'z'|'A'..'Z'|'0'..'9'|'_'|'\'')
;

fragment
DIGIT
    : '0'..'9'
    ;

INT
    : '~'? ('1'..'9') DIGIT*
    | '0'
    | '~'? '0x' HEX_DIGIT+
    ;

WORD
    : '0w' DIGIT+
    | '0wx' HEX_DIGIT+
    ;

FLOAT
    : '~'? UNSIGNEDFLOAT 
    ;

fragment
UNSIGNEDFLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

COMMENT
    :   '(*' ( options {greedy=false;} : . )* '*)' {$channel=HIDDEN;}
    ;
/*
COMMENT
    :   '(*' (COMMENT|'('~'*'|~'(')* '*)' {$channel=HIDDEN;}
    ;
*/

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

CHAR
    : '#"' ( ESC_SEQ | ~('\\'|'"')) '"'
    ;

fragment
EXPONENT : ('e'|'E') '~'? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

fragment
SYMBOL_NOGT
    : '!' | '%' | '&' | '$' | '#' | '+' | '-' | '/' | ':' | '<' | '='
    | '?' | '@' | '\\' | '~' | '`' | '^' | '|' | '*'
    ;

fragment
LONE_SYMBOL
    : '!' | '%' | '&' | '$' | '+' | '/' | '<'
    | '>' | '?' | '@' | '\\'
    //| '~' // XXX Not quite sure what should be done here...
    | '`' | '^'
    ;

fragment
SYMBOL
    : '!' | '%' | '&' | '$' | '#' | '+' | '-' | '/' | ':' | '<' | '='
    | '>' | '?' | '@' | '\\' | '~' | '`' | '^' | '|' | '*'
    ;

// ______________________________________________________________________
// End of MLPlay0.g
