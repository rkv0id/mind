import std/tables
from std/times import DateTime, now
from std/sequtils import mapIt, filterIt
from std/strutils import isEmptyOrWhitespace, join
from std/os import fileExists, removeFile, getFileInfo,
                   splitFile, absolutePath, createHardlink

import norm/sqlite
from norm/model import Model
from norm/pragmas import index, uniqueIndex

from ./repository import mindDbFile, hardFile

type
  File = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    persistent: bool

  Tag = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
    desc: string
  
  FileTag = ref object of Model
    file {.index: "FileTag_file".}: File
    tag {.index: "FileTag_tag".}: Tag
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

proc existsOrInitDb*() =
  if not fileExists mindDbFile:
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

proc extensionsTable(files: seq[string], persistent: bool): Table[string, seq[string]] =
  for path in files:
    let
      (_, name, ext) = path.splitFile
      newPath = if persistent: hardFile(name & ext) else: path.absolutePath
    if persistent:
      if not newPath.fileExists: path.createHardlink newPath
      elif newPath.getFileInfo.id != path.getFileInfo.id:
        raise newException(ValueError, "Mind data store contains a different file with this exact name!")
    result[ext] = result.getOrDefault(ext, @[]) & newPath

proc addTaggedFiles*(files, tagNames: seq[string], persistent = false) =
  let
    at = now()
    extensionsTable = extensionsTable(files, persistent)

  var
    file: File
    tags: seq[Tag]
    tagged: FileTag

  withMindDb: db.transaction:
    tags.add newTag(system=true)
    for name in tagNames:
      tags.add newTag(name)
      try: db.select(tags[^1], "Tag.name = ? and Tag.system = 0", name)
      except: discard

    for ext, paths in extensionsTable.pairs:
      tags[0] = newTag("ext[" & ext & "]", true,
                       "Tracks all tagged " & (
                        if not ext.isEmptyOrWhitespace: ext
                        else: "extensionless"
                       ) & " files.")
      try: db.select(tags[0], "Tag.name = ? and Tag.system = 1", tags[0].name)
      except: discard

      for path in paths:
        file = newFile(path, persistent)
        try: db.select(file, "File.path = ?", path)
        except: discard

        for tag in tags:
          tagged = newFileTag(file, tag, at)
          try: db.select(tagged, "FileTag.tag = ? and File = ?", tag, file)
          except: db.insert tagged

proc deleteTags*(tagNames: seq[string]) =
  var
    tag: Tag
    files: seq[File]
    tagds: seq[FileTag]

  withMindDb: db.transaction:
    for name in tagNames:
      try:
        tag = newTag()
        db.select(tag, "Tag.name = ? and Tag.system = 0", name)
        tagds = @[newFileTag()]
        db.selectOneToMany(tag, tagds)
        files = tagds.mapIt(it.file)
        db.delete tagds
        db.delete tag
        for file in files.mitems:
          tagds = @[newFileTag()]
          db.selectOneToMany(file, tagds)
          if tagds.len <= 1:
            if file.persistent: removeFile file.path
            db.delete file
            db.delete tagds
      except: discard

proc deleteFiles*(paths: seq[string]) =
  var
    file = newFile()
    tagds: seq[FileTag]
  withMindDb: db.transaction:
    for path in paths:
      tagds = @[newFileTag()]
      db.select(file, "File.path = ?", path)
      db.selectOneToMany(file, tagds)
      db.delete tagds
      if file.persistent: removeFile file.path
      db.delete file

proc deleteTagsFromFiles*(paths, tagNames: seq[string]) =
  var tagds: seq[FileTag]
  withMindDb: db.transaction:
    for path in paths:
      tagds = @[newFileTag()]
      db.select(tagds, "File.path = ? and Tag.system = 0 and Tag.name in ('" &
                (tagNames.join("', '")) & "')", path)
      db.delete tagds
      tagds = @[newFileTag()]
      db.select(tagds, "File.path = ?", path)
      if tagds.len == 1:
        if tagds[0].file.persistent: removeFile tagds[0].file.path
        db.delete tagds[0].file
        db.delete tagds

proc syncDb*() =
  var
    files = @[newFile()]
    tagds: seq[FileTag]

  withMindDb: db.transaction:
    db.select(files, "File.persistent = 0")
    files = files.filterIt(not it.path.fileExists)
    for file in files:
      tagds = @[newFileTag()]
      db.selectOneToMany(file, tagds)
      db.delete tagds
    db.delete files
