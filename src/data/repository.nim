from std/os import getDataDir, joinPath, existsOrCreateDir


const MindHomeDir = ".memoed"
let
  mindDataDir = getDataDir().joinPath(MindHomeDir)
  mindFilesDir = mindDataDir.joinPath("files")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc checkRepo*() =
  discard existsOrCreateDir mindDataDir
  discard existsOrCreateDir mindFilesDir

proc hardFile*(filename: string): string = mindFilesDir.joinPath(filename)
