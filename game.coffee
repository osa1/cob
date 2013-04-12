Game = do ->

  luv = Luv
          el: document.getElementById("game-canvas"),
          width: 600,
          height: 400

  dimensions = luv.graphics.getDimensions()
  MAX_BLOCKS_WIDTH  = 10
  MAX_BLOCKS_HEIGHT = 5

  BLOCK_WIDTH  = dimensions.width / MAX_BLOCKS_WIDTH
  BLOCK_HEIGHT = dimensions.height / MAX_BLOCKS_HEIGHT
  BOT_SPEED    = 10 # px/sec

  class Bot
    constructor: (@posx, @posy) ->
      @targetx = @posx
      @targety = @posy
      @onComplete = () ->

    moveTo: (x, y) ->
      @targetx = x
      @targety = y

    draw: ->
      luv.graphics.setColor 255, 255, 255
      luv.graphics.fillRectangle @posx+BLOCK_WIDTH/2, @posy, BLOCK_WIDTH, BLOCK_HEIGHT

    update: (dt) ->
      if @targetx == @posx and @targety == @posy
        return

      delta = dt * BOT_SPEED

      if targetx < posx
        posx -= delta
        if targetx > posx
          posx = targetx
      else if targetx > posx
        posx += delta
        if targetx < posx
          posx = targetx
      else if targety < posy
        posy -= delta
        if targety > posy
          posy = targety
      else if targety > posy
        posy += delta
        if targety < posy
          posy = targety

    bottomPos: ->
      [ @posx + BLOCK_WIDTH / 2, @posy + BLOCK_WIDTH / 2 ]


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


  class Level
    constructor: (@lvlData) ->
      console.log "loading level: #{@lvlData}"
      @bot    = new Bot dimensions.width / 2, 0
      @blocks = []

      for colIdx in [0..@lvlData.length-1]
        col = @lvlData[colIdx]
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
          posy = dimensions.height - (rowIdx * BLOCK_HEIGHT - BLOCK_HEIGHT / 2)

          block = new Block posx, posy, color
          @blocks.push block

    update: (dt) ->
      @bot.update dt

      for block in @blocks
        block.update dt

    draw: ->
      @bot.draw()

      for block in @blocks
        block.draw()

  currentLevel = null

  loadLevel = (lvl) ->
    currentLevel = new Level lvl

  luv.update = (dt) ->
    if currentLevel
      currentLevel.update dt

  luv.draw = ->
    if currentLevel
      currentLevel.draw()

  luv.run()

  loadLevel: loadLevel

window.Game = Game
