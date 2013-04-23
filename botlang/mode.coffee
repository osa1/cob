window.BotlangMode = do -> ->

    words = (str) ->
        obj = {}
        _words = str.split " "
        for w in _words
            obj[w] = true
        return obj

    keywords = words "if"
    builtins = words "red green blue holding"

    startState: ->
        return indent: 0

    token: (stream, state) ->
        if stream.sol()
            state.indent = stream.indentation()

        if stream.eatSpace()
            return null

        ch = stream.next()

        if ch == "#"
            stream.skipToEnd()
            return "comment"

        stream.eatWhile(/[\w\$_\:]/)
        cur = stream.current()

        if (cur.charAt cur.length - 1) == ":"
            state.indent += 4
            return "variable"

        if keywords.propertyIsEnumerable cur
            state.indent += 4
            return "keyword"

        if builtins.propertyIsEnumerable cur
            console.log "builtin"
            return "builtin"

        return "atom"

    indent: (state, textAfter) ->
        return state.indent
