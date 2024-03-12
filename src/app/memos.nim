from std/sets import toHashSet, items
from std/sequtils import mapIt, toSeq
from std/os import getEnv, execShellCmd
from std/strutils import isEmptyOrWhitespace

from regex import re2, findAll

from ../data/memos import updateMemoTags, deleteMemo
from ../data/repository import memoFile, newMemoFile


proc memo*(memoid: string) =
  var tags = newSeq[string]()
  let
    defaultEditor = getEnv("EDITOR")
    memoToOpen =
      if memoid.isEmptyOrWhitespace or memoid == "nil": newMemoFile()
      else: memoFile(memoid)
  
  if execShellCmd(defaultEditor & " " & memoToOpen) == 0:
    let content = readFile memoToOpen
    if content.isEmptyOrWhitespace: deleteMemo memoToOpen
    else:
      tags = content
        .findAll(re2"#[a-zA-Z_]\w*")
        .mapIt(content[it.boundaries][1..^1])
        .toHashSet.toSeq
  
    # TODO: deal with file persistence in memos
    # folder instead before adding tags
    # also don't forget to delete invalidated tags
    updateMemoTags(memoToOpen, tags)
  else: raise newException(IOError, "Something went wrong while trying to open/edit the memo!")
