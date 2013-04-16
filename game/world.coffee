window.toWorldCoordinates_start = (x, y) ->
    [ x * BLOCK_WIDTH, y * BLOCK_HEIGHT ]

window.toWorldCoordinates_center = (x, y) ->
    [ x * BLOCK_WIDTH + BLOCK_WIDTH / 2, y * BLOCK_HEIGHT + BLOCK_HEIGHT / 2 ]

window.fillRect = (x, y) ->
    luv.graphics.fillRectangle x * BLOCK_WIDTH, y * BLOCK_HEIGHT, BLOCK_WIDTH, BLOCK_HEIGHT

window.colOf = Math.floor

window.rowOf = Math.floor
