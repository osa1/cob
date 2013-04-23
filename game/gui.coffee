GuiModule = do ->

    class Bot

        constructor: (@gui, @posx, @posy, @speed = 1.5) ->
            @targetx = @posx
            @targety = @posy

            @busy    = false

            @attachedTo = null
            @onComplete = ->

        bottomPos: ->
            [ @posx, @posy + 0.5 ]

        moveDelta: (x, y) ->
            @targetx = @posx + x
            @targety = @posy + y

        moveTo: (x, y) ->
            @targetx = x
            @targety = y

        attach: (obj) ->
            @attachedTo = obj
            obj.attach this

        remove: ->
            @attachedTo.remove()
            @attachedTo = null

        draw: ->
            @gui.graphics.setColor 255, 255, 255
            fillRect @gui, @posx, @posy

            if @attachedTo
                @attachedTo.draw()

        update: (dt) ->
            delta = dt * @speed

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
            else
                @busy = true

        _forceUpdate: ->
            while @posx != @targetx or @posy != @targety
                @posx = @targetx
                @posy = @targety
                if @attachedTo
                    @attachedTo.setPosRelative()
                @onComplete()


    class Block

        constructor: (@gui, @posx, @posy, @color) ->
            @attached = null

        draw: ->
            @gui.graphics.setColor @color...
            fillRect @gui, @posx, @posy

        setPosRelative: ->
            if @attached
                [bottomx, bottomy] = @attached.bottomPos()
                @posx = bottomx
                @posy = bottomy + 0.5

        update: (dt) ->
            @setPosRelative()

        attach: (obj) ->
            @attached = obj

        remove: () =>
            @attached = null


    class Gui

        constructor: (@internal, @maxBlockHeight, @botSpeed, @drawBot = true) ->
            @map = []

        setLevel: (mapData) ->
            @map = []
            for colIdx in [0..mapData.length-1]
                col = mapData[colIdx]
                newCol = []
                if col.length != 0
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
                                else if row == "b"
                                    [ 0, 0, 255 ]
                                else
                                    [ 255, 234, 173 ]

                            posx = colIdx
                            posy = @maxBlockHeight - rowIdx - 1

                            block = new Block @internal, posx, posy, color
                            newCol.push block

                @map.push newCol

            if @drawBot
                @bot = new Bot @internal, (Math.floor @map.length / 2), 0, @botSpeed

            console.log @bot
            console.log @map

        setBotPos: (col) ->
            if @bot
                @bot.posx = col
                @bot.targetx = col
                @bot.targety = 0
                @bot.posy = 0
                @bot._forceUpdate()

        isBusy: ->
            @bot.busy

        draw: ->
            @internal.graphics.setColor "15BDBA"
            mapWidth = @map.length * @internal.BLOCK_WIDTH
            @internal.graphics.translate ((@internal.graphics.getWidth() - mapWidth) / 2), 0
            @internal.graphics.line 0, 0, 0, @internal.graphics.getHeight()
            @internal.graphics.line mapWidth + @internal.BLOCK_MARGIN, 0, mapWidth + @internal.BLOCK_MARGIN, @internal.graphics.getHeight()

            for col in @map
                for row in col
                    row.draw()

            if @drawBot
                @bot.draw()

        update: (dt) ->
            for col in @map
                for row in col
                    row.update dt

            if @drawBot
                @bot.update dt

        _forceUpdate: ->
            @bot._forceUpdate()

        pick: =>
            @_forceUpdate()

            col = colOf @bot.posx
            @bot.moveTo @bot.posx, @maxBlockHeight - @map[col].length - 1
            @bot.onComplete = =>
                @bot.attach @map[col].pop()
                @bot.moveTo @bot.posx, 0
                @bot.onComplete = =>
                    @bot.onComplete = ->
                        @busy = false

        drop: ->
            @_forceUpdate()

            col = colOf @bot.posx
            @bot.moveDelta 0, @maxBlockHeight - @map[col].length - 2
            @bot.onComplete = =>
                @map[col].push @bot.attachedTo
                @bot.remove()
                @bot.moveTo @bot.posx, 0
                @bot.onComplete = =>
                    @bot.onComplete = ->
                        @busy = false

        moveLeft: ->
            @_forceUpdate()

            @bot.moveDelta -1, 0
            @bot.onComplete = =>
                @bot.onComplete = ->
                    @busy = false

        moveRight: ->
            @_forceUpdate()

            @bot.moveDelta 1, 0
            @bot.onComplete = =>
                @bot.onComplete = ->
                    @busy = false

    Gui: Gui

window.Gui = GuiModule.Gui
