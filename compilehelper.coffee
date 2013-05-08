fs   = require "fs"
path = require "path"
cp   = require "child_process"

goUp = (depth) ->
    if depth == 0
        return ""

    _path = ""
    for i in [0..depth-1]
        _path += "../"
    return _path

mkWatcher = (filePath, depth) -> () ->
    outputFolder = path.join (path.dirname filePath), (goUp depth), "game-js"
    console.log "outputFolder: #{outputFolder}, filePath: #{filePath}"
    ps = cp.spawn "coffee", [ "-c", "-m", "-o", outputFolder, filePath ]
    ps.stdout.on 'data', (data) ->
        console.log data.toString()
    ps.stderr.on 'data', (data) ->
        console.log data.toString()

addWatchers = (folderPath, depth = 0) ->
    files = fs.readdirSync folderPath

    for file in files
        filePath = path.join folderPath, file
        stat     = fs.statSync filePath

        if stat.isDirectory()
            addWatchers filePath, depth + 1
        else if (path.extname file) == ".coffee"
            console.log "file added: #{filePath}, depth: #{depth}"
            fs.watchFile filePath, (mkWatcher filePath, depth)

if process.argv.length < 3
    process.exit()

targetPath = process.argv[2]
addWatchers targetPath
