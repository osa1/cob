window.fillRect = (gui, x, y) ->
    gui.graphics.fillRectangle x * gui.BLOCK_WIDTH + gui.BLOCK_MARGIN, y * gui.BLOCK_HEIGHT, gui.BLOCK_WIDTH - gui.BLOCK_MARGIN, gui.BLOCK_HEIGHT

window.colOf = Math.floor

window.rowOf = Math.floor
