from std/os import getDataDir, joinPath


const MemoedHomeDir = ".memoed"
let
  mindDataDir = getDataDir().joinPath(MemoedHomeDir)
  mindFilesDir = mindDataDir.joinPath("files")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc hardFile*(filename: string): string = mindFilesDir.joinPath(filename)
