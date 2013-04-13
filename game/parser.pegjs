start = functions

ws = [\t\n\r ]

id
  = id:[A-Za-z0-9]+
      { return id.join(""); }

functions
  = function+

function
  = ws* id:id ws* ":" ws* commands:command+
      { return { id: id, commands: commands }; }

command
  = ws* "move" ws+ dir:dir
      { return { cmd: 'move', dir: dir }; }
  / ws* "down"
      { return { cmd: 'down' }; }
  / ws* "call" ws+ id:id
      { return { cmd: 'call', function: id }; }

dir = "left" / "right"
