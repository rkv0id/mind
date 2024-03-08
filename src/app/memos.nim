from std/sets import toHashSet, items
from std/sequtils import mapIt, toSeq
from std/os import getEnv, execShellCmd
from std/strutils import isEmptyOrWhitespace

from regex import re2, findAll

from ../data/entities import addTaggedFiles
from ../data/repository import memoFile, newMemoFile


proc memo*(memoid: string) =
  var tags = newSeq[string]()
  let
    defaultEditor = getEnv("EDITOR")
    memoToOpen =
      if memoid.isEmptyOrWhitespace or memoid == "nil": newMemoFile()
      else: memoFile(memoid)
  
  while tags.len == 0:
    if execShellCmd(defaultEditor & " " & memoToOpen) == 0:
      let content = readFile memoToOpen
      tags = content
        .findAll(re2"#[a-zA-Z_]\w*")
        .mapIt(content[it.boundaries])
        .toHashSet.toSeq
    
      if tags.len == 0:
        echo """
No tag was detected in edited memo!
Make sure to add at least one #hashtag to ensure the memo's retrieval."""
      # TODO: deal with file persistence in memos
      # folder instead before adding tags
      # also don't forget to delete invalidated tags
      else: addTaggedFiles(@[memoToOpen], tags)
    else: raise newException(IOError, "Something went wrong while trying to open/edit the memo!")
