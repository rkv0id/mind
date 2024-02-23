from std/os import getDataDir, joinPath, putEnv

from norm/sqlite import dbHostEnv

from ./daos import createSchemas


const MemoedHomeDir = ".memoed"
let
  mindDataDir = getDataDir().joinPath(MemoedHomeDir)
  mindFilesDir = mindDataDir.joinPath("files")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc hardFile*(filename: string): string = mindFilesDir.joinPath(filename)

proc initDb() =
  putEnv(dbHostEnv, "file://" & mindDbFile)
  createSchemas()
