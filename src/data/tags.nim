import std/[sugar, sets, tables]
from std/times import DateTime, now
from std/mimetypes import newMimetypes, getMimetype
from std/sequtils import mapIt, filterIt, allIt, toSeq
from std/strutils import isEmptyOrWhitespace, join, split
from std/os import fileExists, removeFile, getFileInfo,
                   splitFile, absolutePath, createHardlink

import norm/sqlite

import ./db
from ./repository import hardFile


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

proc readFiles*(predicate: HashSet[string] -> bool): seq[string] =
  var
    tagds = @[newFileTag()]
    tagsByFile: Table[string, HashSet[string]]
  withMindDb: db.transaction: db.selectAll tagds

  for filetag in tagds:
    if not (filetag.file.path in tagsByFile):
      tagsByFile[filetag.file.path] = initHashSet[string]()
    tagsByFile[filetag.file.path].incl filetag.tag.name
  
  tagsByFile.keys.toSeq.filterIt(predicate tagsByFile[it])

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

proc extensionsToPaths(files: seq[string], persistent: bool): Table[string, seq[string]] =
  for path in files:
    let
      (_, name, ext) = path.splitFile
      newPath = if persistent: hardFile(name & ext) else: path.absolutePath
    if persistent:
      if not newPath.fileExists: path.createHardlink newPath
      elif newPath.getFileInfo.id != path.getFileInfo.id:
        raise newException(ValueError, "Mind data store contains a different file with this exact name!")
    result[ext] = result.getOrDefault(ext, @[]) & newPath

func systemTags(extension: string): seq[Tag] =
  const mimeDb = newMimetypes()
  let
    fileTypes = mimeDb.getMimetype(extension).split("/")
    fileExtension = if extension.isEmptyOrWhitespace: "?" else: extension[1..^1]

  result.add newTag("ext[" & fileExtension & "]", true,
                    "Tracks all tagged " & (
                      if not extension.isEmptyOrWhitespace: fileExtension
                      else: "extensionless"
                    ) & " files.")
  for ftype in fileTypes:
    if ftype != fileExtension:
      result.add newTag("type[" & ftype & "]", true,
                        "Tracks all tagged " & ftype & " files.")

proc addTaggedFiles*(files, tagNames: seq[string], persistent = false) =
  let
    at = now()
    extensionsTable = extensionsToPaths(files, persistent)

  var
    file: db.File
    sysTags: seq[Tag]
    tags: seq[Tag]
    tagged: FileTag

  withMindDb: db.transaction:
    for name in tagNames:
      tags.add newTag(name)
      try: db.select(tags[^1], "Tag.name = ? and Tag.system = 0", name)
      except: discard

    for ext, paths in extensionsTable.pairs:
      sysTags = systemTags(ext)
      for tag in sysTags.mitems:
        try: db.select(tag, "Tag.name = ? and Tag.system = 1", tag.name)
        except: discard

      for path in paths:
        file = newFile(path, persistent)
        try: db.select(file, "File.path = ?", path)
        except: discard
        for tag in sysTags & tags:
          tagged = newFileTag(file, tag, at)
          try: db.select(tagged, "FileTag.tag = ? and FileTag.file = ?", tag, file)
          except: db.insert tagged

proc deleteTags*(tagNames: seq[string]) =
  var
    tag: Tag
    files: seq[db.File]
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
          if tagds.allIt(it.tag.system):
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
      if tagds.allIt(it.tag.system):
        if tagds[0].file.persistent: removeFile tagds[0].file.path
        db.delete tagds[0].file
        db.delete tagds
