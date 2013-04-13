Game = do ->

    luv.update = (dt) ->
        if gui
            gui.update dt

    luv.draw = ->
        if gui
            gui.draw()

    luv.run()

window.Game = Game
