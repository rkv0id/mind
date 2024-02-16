from std/os import getDataDir, joinPath


const MemoedHomeDir = ".memoed"
let
  mindDataDir = getDataDir().joinPath(MemoedHomeDir)
  mindMemoDir = getDataDir().joinPath("memos")
  mindDbFile* = mindDataDir.joinPath("data.db")

proc memoFile*(filename: string): string = mindMemoDir.joinPath(filename)
