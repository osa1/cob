window.toWorldCoordinates_start = (x, y) ->
    [ x * BLOCK_WIDTH, y * BLOCK_HEIGHT ]

window.toWorldCoordinates_center = (x, y) ->
    [ x * BLOCK_WIDTH + BLOCK_WIDTH / 2, y * BLOCK_HEIGHT + BLOCK_HEIGHT / 2 ]

window.fillRect = (x, y) ->
    luv.graphics.fillRectangle x - BLOCK_WIDTH / 2, y - BLOCK_HEIGHT / 2, BLOCK_WIDTH, BLOCK_HEIGHT

window.colOf = (x) ->
    ret = x / BLOCK_WIDTH
    Math.floor ret

window.rowOf = (y) ->
    ret y / BLOCK_HEIGHT
    Math.floor ret
