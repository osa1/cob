GAME_SOURCE = "game"
GAME_OUTPUT = "game-js"
BOTLANG_SOURCE = "botlang"
BOTLANG_OUTPUT = "botlang"

fs   = require 'fs'
cp   = require 'child_process'
path = require 'path'

mkTargetDir = ->
  if not fs.existsSync GAME_OUTPUT
    fs.mkdir GAME_OUTPUT

setStreams = (p) ->
  p.stdout.on 'data', (data) ->
    console.log 'stdout: ' + data
  p.stderr.on 'data', (data) ->
    console.log 'stderr: ' + data

task 'build:game', 'rebuild the game', (options) ->
  mkTargetDir()
  for file in fs.readdirSync GAME_SOURCE
    if (path.extname file) == '.coffee'
      setStreams(cp.spawn 'coffee', [ '-c', '-m', '-o', GAME_OUTPUT, (path.join GAME_SOURCE, file) ])

task 'build:parser', 'rebuild the parser', (options) ->
  mkTargetDir()
  setStreams(cp.spawn 'pegjs', [ "-e", "parser", (path.join GAME_SOURCE, 'parser.pegjs'), (path.join GAME_OUTPUT, 'parser.js') ])

task 'build:botlang', 'rebuild botlang module for CodeMirror', (options) ->
  setStreams(cp.spawn 'coffee', [ '-c', '-m', '-o', BOTLANG_OUTPUT, (path.join BOTLANG_SOURCE, 'mode.coffee') ])

task 'clean', '', (options) ->
  cp.spawn 'rm', [ '-rf', GAME_OUTPUT ]

task 'build:all', 'rebuild game and parser', (options) ->
  invoke 'build:parser'
  invoke 'build:botlang'
  invoke 'build:game'
