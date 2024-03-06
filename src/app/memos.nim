from std/os import getEnv, execShellCmd
from std/strutils import isEmptyOrWhitespace

from ../data/repository import memoFile, newMemoFile


proc memo*(memoid: string) =
  let defaultEditor = getEnv("EDITOR")
  let memoToOpen =
    if memoid.isEmptyOrWhitespace or memoid == "nil": newMemoFile()
    else: memoFile(memoid)
  if execShellCmd(defaultEditor & " " & memoToOpen) == 0:
    discard
  else: discard