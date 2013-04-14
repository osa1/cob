window.BotlangMode = do -> ->

    startState: ->
        return indent: 0

    token: (stream, state) ->
        # TODO: atom and fun should be the other way around,
        # but this looks more `normal`, maybe because color scheme
        if stream.sol()
            if stream.skipTo(':')
                stream.next()
                console.log "return cm-fun"
                state.indent = stream.indentation() + 1
                return "atom"
            else
                if stream.indentation() == 0
                    state.indent = 0

        stream.skipToEnd()
        return "fun"

    indent: (state, textAfter) ->
        return state.indent * 4
