from std/os import getDataDir, removeDir, fileExists,
                   existsOrCreateDir, joinPath


const MindHomeDir = ".mind"
let
  mindDataDir = getDataDir().joinPath(MindHomeDir)
  mindFilesDir = mindDataDir.joinPath("files")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc existsOrInitRepo*() =
  discard existsOrCreateDir mindDataDir
  discard existsOrCreateDir mindFilesDir

proc dropRepo*() = removeDir mindDataDir
proc hardFile*(filename: string): string = mindFilesDir.joinPath(filename)
