from std/times import now
from std/hashes import hash
from std/os import getDataDir, removeDir, fileExists,
                   existsOrCreateDir, joinPath


const MindHomeDir = ".mind"
let
  mindDataDir = getDataDir().joinPath(MindHomeDir)
  mindFilesDir = mindDataDir.joinPath("files")
  mindMemosDir = mindDataDir.joinPath("memos")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc existsOrInitRepo*() =
  discard existsOrCreateDir mindDataDir
  discard existsOrCreateDir mindFilesDir
  discard existsOrCreateDir mindMemosDir

proc dropRepo*() = removeDir mindDataDir
proc hardFile*(filename: string): string = mindFilesDir.joinPath(filename)
proc newMemoFile*(): string = mindMemosDir.joinPath("M" & $hash($now()) & ".mem")
proc memoFile*(memoname: string): string =
  let memofilepath = mindMemosDir.joinPath(memoname & ".mem")
  if memofilepath.fileExists: memofilepath
  else: raise newException(ValueError, "Memo '" & memoname & "' not found in store.")
