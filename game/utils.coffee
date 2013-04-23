window.assert = (b, msg) ->
    if not b
        throw new Error ("assertion fail: " + msg)
