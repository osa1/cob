Engine = do ->

  # XXX: Commands' well-formedness should be guaranteed by the parser.

  level   = {}
  currentLevel = null
  history = []
  program = null
  currentFunction = null
  ip = null

  # bot state
  bot = null

  loadLevel = (start, target) ->
    throwSizeError = ->
      throw new Error "start and target maps are not same size."

    if start.length != target.length
      throwSizeError()
      
    for i in [0..start.length-1]
      if start[i].length != target[i].length
        throwSizeError()

    level = start: start, target: target
    currentLevel = start

  loadProgram = (_program) ->
    if not currentLevel
      throw new Error "load a level first"

    if _program.length == 0
      throw new Error "program has no functions."

    history = []
    program = _program
    currentFunction = program[0]
    ip = 0

    bot = posx: (Math.floor level.start.length / 2), block: null

  step = ->
    if not currentFunction
      throw new Error "currentFunction is null"

    if ip >= currentFunction.commands.length
      throw new Error "halt"

    cmd = currentFunction.commands[ip++]

    if cmd.cmd == "move"
      if cmd.dir == "right"
        if bot.posx < level.start.length - 1
          bot.posx++
          history.push cmd
        else
          console.log "wall"
      else
        if bot.posx > 0
          bot.posx--
          history.push cmd
        else
          console.log "wall"

    else if cmd.cmd == "down"
      col = currentLevel[bot.posx]
      if bot.block
        for i in [col.length-1..0] by -1
          if col[i]
            if i < col.length - 2
              col[i+1] = bot.block
              bot.block = null
              history.push cmd
              return
            else
              console.log "col is full"
              return
        console.log "col is empty"
        col[0] = bot.block
        bot.block = null
        history.push cmd

      else
        for i in [col.length-1..0] by -1
          if col[i]
            bot.block = col[i]
            col[i] = null
            history.push cmd
            return
        console.log "col is empty"
        return

    else if cmd.cmd == "call"
      fun = null
      for f in program
        if f.id = cmd.id
          fun = f
          break
      if not fun
        throw new Error "no function named #{cmd.id} in program"
      history.push cmd: "call", id: cmd.id, before: currentFunction.id
      currentFunction = fun
      ip = 0

    else
      throw new error "Unimplemented cmd: #{cmd.cmd}"

  loadLevel: loadLevel,
  loadProgram: loadProgram,
  step: step,
  stepBack: null,
  fastForward: null

window.Engine = Engine
