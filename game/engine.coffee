EngineModule = do ->

    levelFromString = (string) ->
        parts = string.split("|")
        if parts.length != 2 or
              parts[0].length % 7 != 0 or
              parts[1].length % 7 != 0
            console.log string
            throw { reason: "malformed string" }

        stageStr = parts[0]
        goalStr  = parts[1]

        getLevelData = (string) ->
            level = []
            for i in [0..string.length/7-1]
                col = string.slice i * 7, (i + 1) * 7
                levelCol = []
                for cidx in [0..col.length-1]
                    char = col[cidx]
                    # TODO: this part is not tested
                    strToPush = null
                    strToPush =
                        if char == "r"
                            "red"
                        else if char == "g"
                            "green"
                        else if char == "b"
                            "blue"
                        else if char == "y"
                            "yellow"
                    if strToPush
                        levelCol.push strToPush
                level.push levelCol

            return level

        return new Level getLevelData(stageStr), getLevelData(goalStr), 7 # FIXME: hard-coded

    arrEq = (arr1, arr2) ->
        if arr1.length != arr2.length
            return false

        for colIdx in [0..arr1.length-1]
            col1 = arr1[colIdx]
            col2 = arr2[colIdx]
            if col1.length != col2.length
                return false

            for rowIdx in [0..col1.length-1]
                if col1[rowIdx] != col2[rowIdx]
                    return false

        return true

    search = (val, arr) ->
        for i in [0..arr.length - 1]
            if arr[i] == val
                return i
        return null


    class Level

        constructor: (args) ->
            @stage     = args.stage
            @goal      = args.goal
            @toolbox   = args.toolbox
            @hint      = args.hint
            @maxHeight = args.maxHeight

            if @stage.length != @goal.length
                throw { err: "Level can't created", reason: "stage and goal lengths are not equal" }

            for col in @stage
                @maxHeight = Math.max @maxHeight, col.length

        #constructor: (@stage, @goal, @toolbox, @hint, @maxHeight = 0) ->
            #if @stage.length != @goal.length
                #throw { err: "Level can't created", reason: "stage and goal lengths are not equal" }

            #for col in @stage
                #@maxHeight = Math.max @maxHeight, col.length

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
            #assert @program.length != 0, "programs should have at least one function."

            # check for forbidden commands
            for func in @program
                for stmt in func.commands
                    if stmt.cmd == "move"
                        if stmt.dir == "left" and (search "left", @level.toolbox) == null
                            throw Error "left is not in toolbox"
                        else if stmt.dir == "right" and (search "right", @level.toolbox) == null
                            console.log @level.toolbox
                            throw Error "right is not in toolbox"
                    else if stmt.cmd == "down" and (search "pickup", @level.toolbox) == null
                        throw Error "down is not in toolbox"

            # check for function count
            funLength = @program.length
            if funLength != 0 and (search "f" + funLength, @level.toolbox) == null
                throw Error "too many functions"

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

        _cmdDown: (updateGui, forceUpdate) ->
            if @botBlock and @level.tryPush @botPos, @botBlock
                @botBlock = null
                if updateGui
                    @gui.drop forceUpdate
                @ip++
            else if not @botBlock
                popped = @level.tryPop @botPos
                if popped
                    @botBlock = popped
                    if updateGui
                        @gui.pick forceUpdate
                    @ip++
                else
                    throw new Error "column is emmpty!"

            else
                throw new Error "column is full!"

        _cmdMoveLeft: (updateGui, forceUpdate) ->
            if @botPos > 0
                @botPos--
                if updateGui
                    @gui.moveLeft forceUpdate
                @ip++
            else
                throw new Error "moving out of map!"

        _cmdMoveRight: (updateGui, forceUpdate) ->
            if @botPos < @level.getWidth() - 1
                @botPos++
                if updateGui
                    @gui.moveRight forceUpdate
                @ip++
            else
                throw new Error "moving out of map!"

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

        step: (args = {}) ->
            updateGui =
                if not args.updateGui?
                    true
                else
                    args.updateGui
            forceUpdate =
                if not args.forceUpdate?
                    true
                else
                    args.forceUpdate

            if @ip > @currentFun.commands.length - 1
                jmp = @callStack.pop()
                if jmp
                    @history.push cmd: "call", function: jmp.from, from: @currentFun.id, ip: @ip
                    @currentFun = @_lookupFun jmp.from
                    @ip = jmp.ip
                    return
                else
                    if updateGui
                        @gui.step()
                    throw "halt"

            instr = @currentFun.commands[@ip]
            if instr.cmd == "move"
                dir = instr.dir
                if dir == "left"
                    @_cmdMoveLeft updateGui, forceUpdate
                    @history.push instr
                else if dir == "right"
                    @_cmdMoveRight updateGui, forceUpdate
                    @history.push instr

            else if instr.cmd == "down"
                @_cmdDown updateGui, forceUpdate
                @history.push instr

            else if instr.cmd == "call"
                @_cmdCall instr.function

        stepBack: (updateGui = true) ->
            instr = @history.pop()
            if not instr
                return

            if instr.cmd == "move"
                dir = instr.dir
                if dir == "left"
                    @_cmdMoveRight updateGui, true
                    @ip--
                else if dir == "right"
                    @_cmdMoveLeft updateGui, true
                    @ip--

            else if instr.cmd == "down"
                @_cmdDown updateGui, true
                @ip--

            else if instr.cmd == "call"
                @currentFun = @_lookupFun instr.from
                @ip = instr.ip

        run: ->
            try
                while true
                    @step updateGui: true, forceUpdate: false
            catch error
                if error == "halt"
                    if arrEq @level.stage, @level.goal
                        return "correct"
                    else
                        return "incorrect"
                if error != "halt"
                    throw error

        fastForward: ->
            try
                while true
                    @step updateGui: false
            catch error
                if error == "halt" and @gui
                    @gui.setLevel @level.stage
                    @gui.setBotPos @botPos

                    if arrEq @level.stage, @level.goal
                        throw "correct"
                    else
                        throw "incorrect"

                else if error != "halt"
                    throw error


    Level: Level,
    GameEngine: GameEngine,
    levelFromString: levelFromString

window.Level         = EngineModule.Level
window.GameEngine    = EngineModule.GameEngine
window.levelFromString = EngineModule.levelFromString
