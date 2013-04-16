GuiModule = do ->

    class Bot

        constructor: (@posx, @posy) ->
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

        forceUpdate: ->
            while @posx != @targetx or @posy != @targety
                @posx = @targetx
                @posy = @targety
                if @attachedTo
                    @attachedTo.setPosRelative()
                @onComplete()


    class Block

        constructor: (@posx, @posy, @color) ->
            @attached = null

        draw: ->
            luv.graphics.setColor @color...
            fillRect @posx, @posy

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

        constructor: ->
            @map = []

        setLevel: (mapData) ->
            @map = []
            for colIdx in [0..mapData.length-1]
                col = mapData[colIdx]
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
                            else if row == "b"
                                [ 0, 0, 255 ]
                            else
                                [ 255, 234, 173 ]

                        posx = colIdx
                        posy = MAX_BLOCKS_HEIGHT - rowIdx - 1

                        block = new Block posx, posy, color
                        newCol.push block

                @map.push newCol

            @bot = new Bot (Math.floor @map.length / 2), 0

            console.log @bot
            console.log @map

        isBusy: ->
            @bot.busy

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

        forceUpdate: ->
            @bot.forceUpdate()

        # FIXME
        pick: =>
            console.log "gui.pick"
            @forceUpdate()

            col = colOf @bot.posx
            @bot.moveTo @bot.posx, MAX_BLOCKS_HEIGHT - @map[col].length - 1
            @bot.busy = true
            @bot.onComplete = =>
                @bot.attach @map[col].pop()
                @bot.moveTo @bot.posx, 0
                console.log @bot
                @bot.onComplete = =>
                    console.log "pick completed"
                    @bot.busy = false
                    @bot.onComplete = ->

        drop: ->
            console.log "gui.drop"
            @forceUpdate()

            col = colOf @bot.posx
            @bot.moveDelta 0, MAX_BLOCKS_HEIGHT - @map[col].length - 2
            @bot.busy = true
            @bot.onComplete = =>
                @map[col].push @bot.attachedTo
                @bot.remove()
                @bot.moveTo @bot.posx, 0
                @bot.onComplete = =>
                    console.log "drop completed"
                    @bot.busy = false
                    @bot.onComplete = ->

        moveLeft: ->
            console.log "gui.moveLeft"
            @forceUpdate()

            @bot.moveDelta -1, 0
            @bot.onComplete = =>
                console.log "moveLeft completed"
                @bot.busy = false
                @bot.onComplete = ->

        moveRight: ->
            console.log "gui.moveRight"
            @forceUpdate()

            @bot.moveDelta 1, 0
            @bot.onComplete = =>
                console.log "moveRight completed"
                @bot.busy = false
                @bot.onComplete = ->

    Gui: Gui

window.Gui = GuiModule.Gui
