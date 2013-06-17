start = functions

LineTerminator
  = [\n\r\u2028\u2029]

SingleLineComment
  = "#" (!LineTerminator .)*

ws
  = [\t\n\r ]
  / SingleLineComment

id
  = id:[A-Za-z0-9_]+
      { return id.join(""); }

functions
  = p:function* ws*
      { return p; }

function
  = ws* id:id ws* ":" ws* commands:command*
      { return { id: id, commands: commands }; }

command
  = ws* "move" ws+ dir:dir
      { return { cmd: 'move', dir: dir }; }
  / ws* "down"
      { return { cmd: 'down' }; }
  / ws* "call" ws+ id:id
      { return { cmd: 'call', function: id }; }
  / ws* "if" ws+ guard:guard ws+ body:command
      { return { cmd: 'conditional', guard: guard, body: body }; }

guard
  = "red" / "green" / "blue" / "yellow"

dir = "left" / "right"
