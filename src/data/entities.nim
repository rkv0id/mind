import std/[sets, tables]
from std/times import DateTime, now
from std/sequtils import mapIt, filterIt
from std/os import fileExists, removeFile
from std/strutils import isEmptyOrWhitespace, join

import norm/sqlite
from norm/model import Model, cpIgnore
from norm/pragmas import uniqueGroup, uniqueIndex

from ./repository import mindDbFile

type
  File = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    persistent: bool

  Tag = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
    desc: string
  
  FileTag = ref object of Model
    file {.uniqueGroup.}: File
    tag {.uniqueGroup.}: Tag
    at: DateTime

func newFile(path = "", persistent = false): File =
  File(path: path, persistent: persistent)

func newTag(name = "", system = false, desc = ""): Tag =
  Tag(name: name, system: system, desc: desc)

func newFileTag(file = newFile(), tag = newTag(), at = now()): FileTag =
  FileTag(file: file, tag: tag, at: at)


template withMindDb*(body: untyped): untyped =
  let
    db {.inject.} =
      try: open("file://" & mindDbFile, "", "", "")
      except: raise newException(IOError, "Could not establish connection to local database!")
  
  try:
    body
  finally: close db

proc initDb*() =
  if not mindDbFile.fileExists:
    withMindDb: db.createTables newFileTag()

proc readTags*(system = false): seq[tuple[name, desc: string, count: int64]] =
  var
    tags = @[newTag()]
    count: Table[string, int64]

  withMindDb: db.transaction:
    db.select(tags, "Tag.system = ?", system)
    for tag in tags:
      count[tag.name] =
        db.count(FileTag, cond="FileTag.tag = ?", params=tag)
  
  tags.mapIt((name: it.name, desc: it.desc, count: count[it.name]))

proc updateTagName*(name, newName: string) =
  withMindDb: db.transaction:
    try:
      var oldTag = newTag(name)
      db.select(oldTag, "Tag.name = ? and Tag.system = 0", name)
      try:
        var newTag = newTag(newName)
        db.select(newTag, "Tag.name = ? and Tag.system = 0", newName)
        try:
          var tagds = @[newFileTag()]
          db.select(tagds, """
          FileTag.tag = ? AND EXISTS (
            SELECT 1 from FileTag new
            WHERE new.tag = ?
            AND new.file = FileTag.file
          )""", oldTag, newTag)
          db.delete(tagds)
          
          tagds = @[newFileTag()]
          db.selectOneToMany(oldTag, tagds)
          for tagd in tagds: tagd.tag = newTag
          db.update tagds
        except: discard
        db.delete(oldTag)
      except:
        oldTag.name = newName
        db.update oldTag
    except: raise newException(ValueError, "Could not find original tag entry!")

proc updateTagDesc*(name, description: string) =
  withMindDb: db.transaction:
    var tag = newTag()
    try:
      db.select(tag, "Tag.name = ? and Tag.system = 0", name)
      tag.desc = description
      db.update tag
    except: raise newException(ValueError, "Could not find tag entry!")

proc addTaggedFiles*(extensionToPaths: Table[string, seq[string]],
                     tagNames = HashSet[string](), persistent = false) =
  var
    at = now()
    tagged: FileTag
    sysTag: Tag
    userTag: Tag
    file: File
    tags: seq[Tag]

  withMindDb: db.transaction:
    for name in tagNames:
      userTag = newTag(name)
      try: db.select(userTag, "Tag.name = ? and Tag.system = 0", name)
      except: db.insert(userTag, conflictPolicy=cpIgnore)
      tags.add userTag

    for ext in extensionToPaths.keys:
      sysTag = newTag("sys[" & ext & "]", true,
                      "Tracks all tagged " & (
                        if not ext.isEmptyOrWhitespace: ext
                        else: "extensionless"
                      ) & " files.")
      try: db.select(sysTag, "Tag.name = ? and Tag.system = 1", sysTag.name)
      except: db.insert(sysTag, conflictPolicy=cpIgnore)
      for path in extensionToPaths[ext]:
        file = newFile(path, persistent)
        try: db.select(file, "File.path = ?", path)
        except:
          db.insert(file, conflictPolicy=cpIgnore)
          tagged = newFileTag(file, sysTag, at)
          db.insert(tagged, conflictPolicy=cpIgnore)
        for tag in tags:
          tagged = newFileTag(file, tag)
          db.insert(tagged, conflictPolicy=cpIgnore)

proc deleteTags*(tagNames: HashSet[string]) =
  var
    tag: Tag
    tagds: seq[FileTag]

  withMindDb: db.transaction:
    for name in tagNames:
      try:
        tag = newTag()
        db.select(tag, "Tag.name = ? and Tag.system = 0", name)
        tagds = @[newFileTag()]
        db.selectOneToMany(tag, tagds)
        db.delete tagds
        db.delete tag
      except: discard

proc deleteFiles*(paths: seq[string]) =
  var
    file: File
    tagds: seq[FileTag]

  withMindDb: db.transaction:
    for path in paths:
      try:
        file = newFile()
        db.select(file, "File.path = ?", path)
        tagds = @[newFileTag()]
        db.selectOneToMany(file, tagds)
        db.delete tagds
        if file.persistent: removeFile file.path
        db.delete file
      except: discard

proc deleteTagsFromFiles*(paths: seq[string], tagNames: HashSet[string]) =
  var
    file: File
    tagds: seq[FileTag]
  
  withMindDb: db.transaction:
    for path in paths:
      try:
        file = newFile()
        db.select(file, "File.path = ?", path)
        tagds = @[newFileTag()]
        db.selectOneToMany(file, tagds)
        var toDelete =
          tagds.filterIt(it.tag.name in tagNames and not it.tag.system)
        if toDelete.len < (tagds.len - 1): db.delete toDelete
        else:
          db.delete tagds
          if file.persistent: removeFile file.path
          db.delete file
      except: discard
