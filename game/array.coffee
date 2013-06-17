Array.prototype.remove = (from, to) ->
    rest = @slice ((to or from) + 1 or @length)
    @length =
        if from < 0
            this.length + from
        else
            from
    return @push.apply this, rest

Array.prototype.search = (val) ->
    for i in [0..@length-1]
        if @[i] == val
            return i
    return null
