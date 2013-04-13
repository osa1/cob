GuiModule = do ->

    class Bot

        constructor: (@posx, @posy) ->
            @targetx = @posx
            @targety = @posy

            @busy    = false

            @attachedTo = null
            @onComplete = ->

        bottomPos: ->
            [ @posx, @posy + BLOCK_HEIGHT / 2 ]

        moveGridDelta: (x, y) ->
            @targetx = @posx + x * BLOCK_WIDTH
            @targety = @posy + y * BLOCK_HEIGHT

        draw: ->
            luv.graphics.setColor 255, 255, 255
            fillRect @posx, @posy

            if @attachedTo
                @attachedTo.draw()

        update: (dt) ->
            delta = dt * BOT_SPEED

            if @targetx < @posx
                if @targetx > @posx - delta
                    @posx = @targetx
                else
                    @posx -= delta

            else if @targetx > @posx
                if @targetx < @pox + delta
                    @posx = @targetx
                else
                    @posx += delta

            else if @targety < @posy
                if @targety > @posy - delta
                    @posy = @targety
                else
                    @posy -= delta

            else if @targety > @posy
                if @targety < @posy + delta
                    @posy = @targety
                else
                    @posy += delta

            if @attachedTo
                @attachedTo.update(dt)

            if @targetx == @posx and @targety == @posy
                @onComplete()


    class Block

        constructor: (@posx, @posy, @color) ->
            @attached = null

        draw: ->
            luv.graphics.setColor @color...
            fillRect @posx, @posy - BLOCK_HEIGHT # FIXME: last part should be removed

        update: (dt) ->
            if @attached
                [bottomx, bottomy] = @attached.bottomPos()
                @posx = bottomx
                @posy = bottomy + BLOCK_WIDTH / 2

        attach: (obj) ->
            @attached = obj

        detach: () =>
            @attached = null


    class Gui

        constructor: ->
            @map = []

        setLevel: (mapData) ->
            @mapHeight = mapData.getHeight()
            @mapHeight_blocks = @mapHeight / BLOCK_HEIGHT
            @mapWidth_blocks = @mapWidth / BLOCK_WIDTH

            @mapWidth  = mapData.getWidth()
            @map = []
            for colIdx in [0..mapData.stage.length-1]
                col = mapData.stage[colIdx]
                newCol = []
                for rowIdx in [0..col.length-1]
                    row = col[rowIdx]
                    if row == null
                        break
                    else
                        color =
                            if row == "r"
                                [ 255, 0, 0 ]
                            else if row == "g"
                                [ 0, 255, 0 ]
                            else
                                [ 0, 0, 255 ]

                        posx = colIdx * BLOCK_WIDTH + BLOCK_WIDTH / 2
                        posy = SCREEN_HEIGHT - (rowIdx * BLOCK_HEIGHT - BLOCK_HEIGHT / 2)

                        block = new Block posx, posy, color
                        newCol.push block

                @map.push newCol

            @bot = new Bot ((@map.length / 2) * BLOCK_WIDTH + BLOCK_WIDTH / 2), BLOCK_HEIGHT / 2

            console.log @bot
            console.log @map

        draw: ->
            for col in @map
                for row in col
                    row.draw()

            @bot.draw()

        update: (dt) ->
            for col in @map
                for row in col
                    row.update dt

            @bot.update dt

        # FIXME
        pick: ->
            #col = colOf @bot.posx
            #@bot.moveGridDelta 0, @mapHeight_blocks - col.length
            #@bot.onComplete = ->
                #@bot.attach @map[col].pop()
                #@bot.attachedTo.attach @bot

        drop: ->

        moveLeft: ->
            console.log "gui.moveLeft"
            @bot.moveGridDelta -1, 0

        moveRight: ->
            console.log "gui.moveRight"
            @bot.moveGridDelta 1, 0

    Gui: Gui

window.Gui = GuiModule.Gui
