
class window.GuiTimer

    constructor: (args...) ->
        @gui = new Gui args...

        @queue = []

        # so method callbacks don't work as I expected in JavaScript,
        # use enumerations for now.
        @cmds =
            pick: 1,
            drop: 2,
            moveLeft: 3,
            moveRight: 4

    setLevel: (mapData) ->
        @gui.setLevel mapData

    setBotPos: (col) ->
        @gui.setBotPos col
        @queue = []

    getBot: ->
        return @gui.bot

    draw: ->
        @gui.draw()

    step: ->
        if @queue.length != 0
            cmd = @queue[0]
            @queue = @queue.slice(1)

            switch cmd
                when @cmds.pick       then @gui.pick()
                when @cmds.drop       then @gui.drop()
                when @cmds.moveLeft   then @gui.moveLeft()
                when @cmds.moveRight  then @gui.moveRight()
            return true
        return false

    update: (dt) ->
        @gui.update(dt)
        if not @gui.isBusy()
            @step()

    _forceUpdate: ->
        while @step()
            1

    pick: (fastForward) ->
        if fastForward
            @_forceUpdate()
        @queue.push @cmds.pick

    drop: (fastForward) ->
        if fastForward
            @_forceUpdate()
        @queue.push @cmds.drop

    moveLeft: (fastForward) ->
        if fastForward
            @_forceUpdate()
        @queue.push @cmds.moveLeft

    moveRight: (fastForward) ->
        if fastForward
            @_forceUpdate()
        @queue.push @cmds.moveRight
