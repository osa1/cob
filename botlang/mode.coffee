window.BotlangMode = do -> ->

    startState: ->
        return indent: 0

    token: (stream, state) ->
        # TODO: atom and fun should be the other way around,
        # but this looks more `normal`, maybe because color scheme
        if stream.peek() == "#"
            stream.skipToEnd()
            state.indent = stream.indentation()
            return "comment"

        if stream.sol()
            if stream.skipTo(':')
                state.indent = stream.indentation() + 4
                return "atom"
            else
                state.indent = stream.indentation()

        stream.next()
        return "fun"

    indent: (state, textAfter) ->
        return state.indent
