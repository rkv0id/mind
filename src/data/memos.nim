import std/[sugar, sets, tables]
from std/times import now
from std/strutils import join
from std/os import removeFile
from std/sequtils import filterIt, toSeq

import norm/sqlite
import ./db


proc readMemos*(predicate: HashSet[string] -> bool): seq[string] =
  var
    tagds = @[newFileTag()]
    tagsByFile: Table[string, HashSet[string]]
  withMindDb: db.transaction: db.select(tagds, "File.memo = 1")

  for filetag in tagds:
    if not (filetag.file.path in tagsByFile):
      tagsByFile[filetag.file.path] = initHashSet[string]()
    tagsByFile[filetag.file.path].incl filetag.tag.name
  
  tagsByFile.keys.toSeq.filterIt(predicate tagsByFile[it])

proc updateMemoTags*(memoFilePath: string, tagNames: seq[string]) =
  let at = now()
  var
    file: db.File
    tag: Tag
    tagged: FileTag
    taggedToDelete = @[newFileTag()]
  
  withMindDb: db.transaction:
    file = newFile(memoFilePath, memo=true)
    try: db.select(file, "File.path = ? and File.memo = 1", memoFilePath)
    except: discard

    tag = newTag("sys[memo]", true, "Tracks all memos (tagged and untagged).")
    try: db.select(tag, "Tag.name = ? and Tag.system = 1", tag.name)
    except: discard

    tagged = newFileTag(file, tag, at)
    try: db.select(tagged, "FileTag.tag = ? and FileTag.file = ?", tag, file)
    except: db.insert tagged

    db.select(taggedToDelete, "FileTag.file = ? and Tag.name not in ('" & (tagNames.join("', '")) & "')", file)
    db.delete taggedToDelete

    for name in tagNames:
      tag = newTag(name)
      try: db.select(tag, "Tag.name = ? and Tag.system = 0", tag.name)
      except: discard

      tagged = newFileTag(file, tag, at)
      try: db.select(tagged, "FileTag.tag = ? and FileTag.file = ?", tag, file)
      except: db.insert tagged

proc deleteMemo*(memoFilePath: string) =
  var
    file = newFile()
    tagds = @[newFileTag()]
  
  withMindDb: db.transaction:
    try:
      db.select(file, "File.path = ? and File.memo = 1", memoFilePath)
      db.selectOneToMany(file, tagds)
      db.delete tagds
      db.delete file
    except: discard
    finally: removeFile memoFilePath
