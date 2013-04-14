EngineModule = do ->

    # make column heights in a map equal by adding `null` spaces.
    fixColHeights = (lvlData) ->
        maxHeight = 0
        for col in lvlData
            maxHeight = Math.max col.length, maxHeight

        ret = []
        for col in lvlData
            newCol = []
            for r in col
                newCol.push r

            if maxHeight != col.length
                for i in [0..maxHeight - col.length - 1]
                    newCol.push null
            ret.push newCol
        return ret


    class Level

        constructor: (@stage, @goal) ->
            @_width  = @stage.length
            @_height = @stage[0].length

            for col in @stage
                if col.length != @_height
                    throw new Error "Level data is not well-formed. (different col heights)"

        getHeight: ->
            return @_height

        getWidth: ->
            return @_width

        tryPop: (col) ->
            assert 0 <= col < @_width, "pop: col is out of bounds: #{col}"

            colData = @stage[col]
            for i in [@_height-1..0] by -1
                if colData[i] != null
                    r = colData[i]
                    colData[i] = null
                    return r
            return null

        tryPush: (col, val) ->
            assert 0 <= col < @_width, "tryPush: col is out of bounds: #{col}"

            colData = @stage[col]
            if colData[@_height-1]
                # col is full
                return false

            for i in [@_height-2..0] by -1
                if colData[i] != null
                    colData[i+1] = val
                    return true
                else if i == 0
                    # col is empty
                    colData[0] = val
                    return true

            return false


    class GameEngine

        constructor: (@level, @program, @gui, @debug = false) ->
            assert @program.length != 0, "programs should have at least one function."

            if @gui
                @gui.setLevel(@level.stage)
            else
                @gui =
                    pick: ->
                    drop: ->
                    moveLeft: ->
                    moveRight: ->

            @history    = []
            @ip         = 0 # instruction pointer
            @currentFun = @program[0]

            # bot state
            @botPos     = Math.floor @level.getWidth() / 2
            @botBlock   = null

        _lookupFun: (funName) ->
            for f in @program
                if f.id == funName
                    return f
            return null

        _cmdDown: (updateGui) ->
            if @botBlock and @level.tryPush @botPos, @botBlock
                @ip++
                @botBlock = null
                if updateGui
                    @gui.drop()
                return true
            else if not @botBlock
                popped = @level.tryPop @botPos
                if popped
                    @botBlock = popped
                    @ip++
                    if updateGui
                        @gui.pick()
                    return true

        _cmdMoveLeft: (updateGui) ->
            if @botPos > 0
                @botPos--
                @ip++
                if updateGui
                    @gui.moveLeft()
                return true

        _cmdMoveRight: (updateGui) ->
            if @botPos < @level._width - 1
                @botPos++
                @ip++
                if updateGui
                    @gui.moveRight()
                return true

        _cmdCall: (funName) ->
            fun = @_lookupFun funName
            if fun
                @currentFun = fun
                @ip = 0
                return true
            else
                throw new Error "function is not defined: #{funName}"

        step: (updateGui = true) ->
            if @debug
                console.log "@ip: #{@ip}, @currentFun.commands.length: #{@currentFun.commands.length}"

            if @ip > @currentFun.commands.length - 1
                throw "halt"
                return

            instr = @currentFun.commands[@ip]
            console.log instr
            if instr.cmd == "move"
                dir = instr.dir
                if dir == "left"
                    if @_cmdMoveLeft updateGui
                        @history.push instr
                else if dir == "right"
                    if @_cmdMoveRight updateGui
                        @history.push instr

            else if instr.cmd == "down"
                if @_cmdDown updateGui
                    @history.push instr

            else if instr.cmd == "call"
                if @_cmdCall instr.function
                    @history.push cmd: "call", function: instr.function, from: @currentFunction.id

            else
                throw new Error "unimplemedted cmd: #{instr.cmd}"

            if @debug
                console.log @level
                console.log "botPos: #{@botPos}, botBlock: #{@botBlock}"

        stepBack: ->
            # TODO
            throw new Error "stepBack not yet implemented"

        fastForward: ->
            try
                while true
                    @step false
            catch error
                if error == "halt" and @gui
                    @gui.setLevel @level.stage
                else if error != "halt"
                    throw error


    Level: Level,
    GameEngine: GameEngine,
    fixColHeights: fixColHeights

window.Level         = EngineModule.Level
window.GameEngine    = EngineModule.GameEngine
window.fixColHeights = EngineModule.fixColHeights
