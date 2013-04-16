EngineModule = do ->

    levelFromString = (string) ->
        parts = string.split("|")
        if parts.length != 2 or
              parts[0].length % 5 != 0 or
              parts[1].length % 5 != 0
            throw { reason: "malformed string" }

        stageStr = parts[0]
        goalStr  = parts[1]

        getLevelData = (string) ->
            level = []
            for i in [0..string.length/5-1]
                col = string.slice i * 5, (i + 1) * 5
                levelCol = []
                for cidx in [0..col.length-1]
                    char = col[cidx]
                    if char != '-'
                        levelCol.push char
                level.push levelCol

            return level

        return new Level getLevelData(stageStr), getLevelData(goalStr)


    class Level

        constructor: (@stage, @goal, @maxHeight = 0) ->
            if @stage.length != @goal.length
                throw { err: "Level can't created", reason: "stage and goal lengths are not equal" }

            for col in @stage
                @maxHeight = Math.max @maxHeight, col.length

        getWidth: ->
            return @stage.length

        tryPop: (col) ->
            assert 0 <= col < @getWidth(), "pop: col is out of bounds: #{col}"

            colData = @stage[col]
            if colData.length == 0
                return null
            return colData.pop()

        tryPush: (col, val) ->
            assert 0 <= col < @getWidth(), "tryPush: col is out of bounds: #{col}"

            colData = @stage[col]
            if colData.length == @maxHeight
                # col is full
                return false

            colData.push val
            return true

        exportStage: ->
            # TODO: This part needs more testing
            lvlstr_arr = []
            for col in @stage
                colstr_arr = []
                for i in [0..@maxHeight]
                    if col[i]
                        colstr_arr.push col[i]
                    else
                        colstr_arr.push "-"
                lvlstr_arr.push colstr_arr.join ""
            return lvlstr_arr.join ""



    class GameEngine

        constructor: (@level, @program, @gui, @targetGui, @debug = false) ->
            assert @program.length != 0, "programs should have at least one function."

            if @gui
                @gui.setLevel @level.stage
            else
                @gui =
                    pick: ->
                    drop: ->
                    moveLeft: ->
                    moveRight: ->

            if @targetGui
                @targetGui.setLevel @level.goal

            @history    = []
            @ip         = 0 # instruction pointer
            @currentFun = @program[0]
            @callStack  = []

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
                    if updateGui
                        @gui.pick()
                    return true

        _cmdMoveLeft: (updateGui) ->
            if @botPos > 0
                @botPos--
                if updateGui
                    @gui.moveLeft()
                return true

        _cmdMoveRight: (updateGui) ->
            if @botPos < @level.getWidth() - 1
                @botPos++
                if updateGui
                    @gui.moveRight()
                return true

        _cmdCall: (funName) ->
            fun = @_lookupFun funName
            if fun
                @ip++
                @history.push cmd: "call", function: funName, from: @currentFun.id, ip: @ip
                @callStack.push from: @currentFun.id, ip: @ip
                @ip = 0

                @currentFun = fun
            else
                throw new Error "unimplemedted cmd: #{instr.cmd}"

        step: (updateGui = true) ->
            if @debug
                console.log "@ip: #{@ip}, @currentFun.commands.length: #{@currentFun.commands.length}"

            if @ip > @currentFun.commands.length - 1
                jmp = @callStack.pop()
                if jmp
                    console.log "jumping"
                    console.log jmp
                    @history.push cmd: "call", function: jmp.from, from: @currentFun.id, ip: @ip
                    @currentFun = @_lookupFun jmp.from
                    @ip = jmp.ip
                else
                    throw "halt"

            instr = @currentFun.commands[@ip]
            if instr.cmd == "move"
                dir = instr.dir
                if dir == "left"
                    if @_cmdMoveLeft updateGui
                        @history.push instr
                        @ip++
                else if dir == "right"
                    if @_cmdMoveRight updateGui
                        @history.push instr
                        @ip++

            else if instr.cmd == "down"
                if @_cmdDown updateGui
                    @history.push instr
                    @ip++

            else if instr.cmd == "call"
                @_cmdCall instr.function

        stepBack: (updateGui = true) ->
            instr = @history.pop()
            if not instr
                return

            if instr.cmd == "move"
                dir = instr.dir
                if dir == "left"
                    @_cmdMoveRight updateGui
                    @ip--
                else if dir == "right"
                    @_cmdMoveLeft updateGui
                    @ip--

            else if instr.cmd == "down"
                @_cmdDown updateGui
                @ip--

            else if instr.cmd == "call"
                @currentFun = @_lookupFun instr.from
                @ip = instr.id

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
    levelFromString: levelFromString

window.Level         = EngineModule.Level
window.GameEngine    = EngineModule.GameEngine
window.levelFromString = EngineModule.levelFromString
