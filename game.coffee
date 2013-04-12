
GRID_HEIGHT = 10
GRID_WIDTH  = 8

class Level
  constructor: (dimensions, @goal, @start) ->
    @blockWidth  = dimensions.width / GRID_WIDTH
    @blockHeight = dimensions.height / GRID_HEIGHT

    @map = @start

  draw: ->
    for columnIdx in [0..@map.length-1]
      column = @map[columnIdx]
      for blockIdx in [0..column.length-1]
        char = column.charAt(blockIdx)

        if char == "r"
          color = [255, 0, 0]
        else if char == "g"
          color = [0, 255, 0]
        else
          color = [0, 0, 255]

        luv.graphics.setColor color...

        luv.graphics.fillRectangle(
          columnIdx * @blockWidth,
          (GRID_HEIGHT - blockIdx - 1) * @blockHeight,
          @blockWidth,
          @blockHeight)

class Lift
  constructor: (@posx, @posy) ->
    @speedx = 10 # px / second
    @speedy = 10

  draw: ->
    luv.graphics.print "lift", @posx * GRID_WIDTH, @posy * GRID_HEIGHT

  update: (dt) ->



luv = Luv
        el: document.getElementById("game-canvas"),
        width: 600,
        height: 400

level   = new Level luv.graphics.getDimensions(), ["rrr"], ["g", "r", "b"]
bubbles = []

rand = (min, max) ->
  Math.floor (Math.random() * (max - min + 1)) + min

class Bubble
  constructor: ->
    sd = luv.graphics.getDimensions()

    @x  = rand 25, sd.width - 25
    @y  = sd.height + rand 50, 100
    @r  = rand 10, 40
    @vy = rand 30, 80


luv.load = ->
  for i in [1..100]
    bubbles.push new Bubble()
  luv.graphics.setBackgroundColor 255, 255, 255

luv.update = (dt) ->
  for i in [0..bubbles.length-1]
    bubble = bubbles[i]
    bubble.y -= bubble.vy * dt

    if bubble.y < -50
      bubbles[i] = new Bubble()

luv.draw = () ->
  level.draw()

  #sd = luv.graphics.getDimensions()
  #for i in [0..bubbles.length-1]
    #bubble = bubbles[i]
    #luv.graphics.setColor 255, 98, 0
    #luv.graphics.fillCircle bubble.x, bubble.y, bubble.r

    #luv.graphics.setLineWidth 255, 255, 200
    #luv.graphics.setColor 255, 255, 200
    #luv.graphics.strokeCircle bubble.x, bubble.y, bubble.r

    #luv.graphics.fillCircle(
      #bubble.x - bubble.r / 2,
      #bubble.y - bubble.r / 2.5,
      #bubble.r / 3)

    #luv.graphics.setColor(255, 255, 255)
    #fps = Math.round luv.timer.getFPS()
    #luv.graphics.print "FPS: " + fps, sd.width - 40, 10

luv.run()
