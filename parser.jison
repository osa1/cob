%lex

%%
\s+                   /* skip whitespace */
"move"                return 'MOVE';
"left"                return 'LEFT';
"right"               return 'RIGHT';
"down"                return 'DOWN';
":"                   return 'COLON';
\w+                   return 'ID';

<<EOF>>               return 'EOF';

/lex

%start program

%%

program
  : programs EOF
    { return $1; }
  ;

programs
  : program programs
    { $$ = ([$1]).concat($2); }
  | program
    { $$ = [$1]; }
  ;

program
  : ID COLON commands
    { $$ = { id: $1, commands: $3 }; }
  ;

commands
  : command
    { $$ = [$1]; }
  | command commands
    { $$ = ([$1]).concat($2); }
  ;

command
  : MOVE dir
    { $$ = { cmd: 'move', dir: $2 }; }
  | DOWN
    { $$ = { cmd: 'down' }; }
  ;

dir
  : LEFT
    { $$ = "left"; }
  | RIGHT
    { $$ = "right"; }
  ;
