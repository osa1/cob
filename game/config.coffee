window.SCREEN_WIDTH  = 600
window.SCREEN_HEIGHT = 400

window.MAX_BLOCKS_WIDTH  = 10
window.MAX_BLOCKS_HEIGHT = 8 # 7 blocks + 1 bot

window.luv = Luv
              el     : document.getElementById("game-canvas"),
              width  : SCREEN_WIDTH,
              height : SCREEN_HEIGHT,

window.BLOCK_WIDTH  = SCREEN_WIDTH  / MAX_BLOCKS_WIDTH
window.BLOCK_HEIGHT = SCREEN_HEIGHT / MAX_BLOCKS_HEIGHT
window.BOT_SPEED    = 1.5 # grids/sec
#window.BOT_SPEED    = 100 # px/sec
