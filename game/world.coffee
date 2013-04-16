window.fillRect = (gui, x, y) ->
    gui.graphics.fillRectangle x * gui.BLOCK_WIDTH, y * gui.BLOCK_HEIGHT, gui.BLOCK_WIDTH, gui.BLOCK_HEIGHT

window.colOf = Math.floor

window.rowOf = Math.floor
