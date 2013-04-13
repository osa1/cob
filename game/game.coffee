# TODO:
#  - Make distinguished world coordinates and grid coordintes systems.
#    Level should contain block coordinates in it's own system, then to draw
#    coordinates should be translated accordingly. Same for bot and blocks.

Game = do ->

  class Bot
    constructor: (@posx, @posy, @level) ->
      @targetx = @posx
      @targety = @posy
      @onComplete = ->
      @attachedTo = null

    moveTo: (x, y) ->
      @targetx = x
      @targety = y

    draw: ->
      luv.graphics.setColor 255, 255, 255
      luv.graphics.fillRectangle(
        @posx + BLOCK_WIDTH / 2,
        @posy - BLOCK_HEIGHT / 2,
        BLOCK_WIDTH,
        BLOCK_HEIGHT)

    update: (dt) ->
      if @targetx == @posx and @targety == @posy
        return

      delta = dt * BOT_SPEED

      # FIXME: this can cause flickering on slow systems,
      # make pos = target if delta > diff
      if @targetx < @posx
        @posx -= delta
        if @targetx > @posx
          @posx = @targetx
      else if @targetx > @posx
        @posx += delta
        if @targetx < @posx
          @posx = @targetx
      else if @targety < @posy
        @posy -= delta
        if @targety > @posy
          @posy = @targety
      else if @targety > @posy
        @posy += delta
        if @targety < @posy
          @posy = @targety

      if @targetx == @posx and @targety == @posy
        @onComplete()
        @onComplete = ->

    bottomPos: ->
      [ @posx, @posy + BLOCK_HEIGHT / 2 ]

    runCmd: (cmd) ->
      if cmd.cmd == "move"
        if cmd.dir == "left"
          @targetx -= BLOCK_WIDTH
        else if cmd.dir == "right"
          @targetx += BLOCK_WIDTH
        else
          console.log "ERROR: invalid dir: #{cmd.dir}"
      else if cmd.cmd == "down"
        console.log "down"
        col = (@posx + BLOCK_WIDTH / 2) / BLOCK_WIDTH
        console.log "bot col: #{col}"
        [ topBlockPos, topBlock ] = @level.topBlock col
        if @attachedTo == null

          @onComplete = =>
            topBlock.attach this
            @targety = BLOCK_HEIGHT / 2
            @attachedTo = topBlock

          @targety = topBlockPos - BLOCK_HEIGHT / 2
        else
          @onComplete = =>
            topBlock.detach()
            @targety = BLOCK_HEIGHT / 2
            @atachedTo = null

          @targety = topBlockPos - BLOCK_HEIGHT

      else
        console.log "ERROR: invalid cmd: #{cmd.cmd}"


  class Block
    constructor: (@posx, @posy, @color) ->
      @attached = null

    draw: ->
      luv.graphics.setColor @color...
      luv.graphics.fillRectangle(
        @posx + BLOCK_WIDTH / 2,
        @posy - BLOCK_HEIGHT / 2,
        BLOCK_WIDTH,
        BLOCK_HEIGHT)

    update: ->
      if @attached
        [bottomx, bottomy] = @attached.bottomPos()
        @posx = bottomx
        @posy = bottomy + BLOCK_WIDTH / 2

    attach: (obj) ->
      @attached = obj

    detach: () ->
      @attached = null


  class Level
    constructor: (@lvlData) ->
      console.log "loading level: #{@lvlData}"
      @bot    = new Bot SCREEN_WIDTH / 2 - BLOCK_WIDTH / 2, BLOCK_HEIGHT / 2, this
      # FIXME: this part should be removed  ^^^^^^^^^^^^^^^^^^
      @blocks = []

      for colIdx in [0..@lvlData.length-1]
        col = @lvlData[colIdx]
        col_ = []
        for rowIdx in [0..col.length-1]
          row = col.charAt rowIdx

          color =
            if row == "r"
              [ 255, 0, 0 ]
            else if row == "g"
              [ 0, 255, 0 ]
            else
              [ 0, 0, 255 ]

          posx = colIdx * BLOCK_WIDTH - BLOCK_WIDTH / 2
          posy = SCREEN_HEIGHT - (rowIdx * BLOCK_HEIGHT - BLOCK_HEIGHT / 2)

          block = new Block posx, posy, color
          col_.push block

        @blocks.push col_

    update: (dt) ->
      @bot.update dt

      for col in @blocks
        for block in col
          block.update dt

    draw: ->
      @bot.draw()

      for col in @blocks
        for block in col
          block.draw()

    topBlock: (col) ->
      console.log "level col: #{col}"
      [ SCREEN_HEIGHT - (@blocks[col].length - 1) * BLOCK_HEIGHT, @blocks[col][@blocks[col].length-1] ]

  currentLevel = null

  loadLevel = (lvl) ->
    currentLevel = new Level lvl

  runProgram = (program) ->
    if currentLevel == null
      console.log "load a level first"
      return

    currentLevel.bot.runCmd program[0].commands[0]

  luv.update = (dt) ->
    if currentLevel
      currentLevel.update dt

  luv.draw = ->
    if currentLevel
      currentLevel.draw()

  luv.run()

  loadLevel: loadLevel,
  runProgram: runProgram

window.Game = Game
