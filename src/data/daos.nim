import std/[sets, tables]
from std/os import fileExists
from std/sequtils import mapIt, toSeq
from std/times import DateTime, now
from std/options import Option, none, some

import norm/sqlite
from norm/model import Model, cpIgnore
from norm/pragmas import uniqueGroup, uniqueIndex

from ./repository import mindDbFile, checkRepo

type
  FileDao = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    persistent: bool

  TagDao = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
    desc: string
  
  Tagged = ref object of Model
    file {.uniqueGroup.}: FileDao
    tag {.uniqueGroup.}: TagDao
    at: DateTime

func newFile(path = "", persistent = false): FileDao =
  FileDao(path: path, persistent: persistent)

func newTag(name = "", system = false, desc = ""): TagDao =
  TagDao(name: name, system: system, desc: desc)

func newTagged(file = newFile(), tag = newTag(), at = now()): Tagged =
  Tagged(file: file, tag: tag, at: at)


template withMindDb*(body: untyped): untyped =
  checkRepo()
  let
    init = not mindDbFile.fileExists
    db {.inject.} =
      try: open("file://" & mindDbFile, "", "", "")
      except: raise newException(IOError, "Could not establish connection to local database!")
  
  try:
    if init: db.createTables newTagged()
    body
  finally: close db

proc addTaggedFiles*(extensionToPaths: Table[string, seq[string]],
                     tagNames = HashSet[string](), persistent = false) =
  var
    at = now()
    tagged: Tagged
    sysTag: TagDao
    userTag: TagDao
    file: FileDao
    tags: seq[TagDao]
    
  withMindDb: db.transaction:
    for name in tagNames:
      userTag = newTag(name)
      try: db.select(userTag, "TagDao.name = ? and TagDao.system = 0", name)
      except: db.insert(userTag, conflictPolicy=cpIgnore)
      tags.add userTag

    for ext in extensionToPaths.keys:
      sysTag = newTag(ext, true)
      try: db.select(sysTag, "TagDao.name = ? and TagDao.system = 1", ext)
      except: db.insert(sysTag, conflictPolicy=cpIgnore)
      for path in extensionToPaths[ext]:
        file = newFile(path, persistent)
        try: db.select(file, "FileDao.path = ?", path)
        except:
          db.insert(file, conflictPolicy=cpIgnore)
          tagged = newTagged(file, sysTag, at)
          db.insert(tagged, conflictPolicy=cpIgnore)
        for tag in tags:
          tagged = newTagged(file, tag)
          db.insert(tagged, conflictPolicy=cpIgnore)

proc updateTagName*(name, newName: string) =
  withMindDb: db.transaction:
    try:
      var oldTag = newTag(name)
      db.select(oldTag, "TagDao.name = ? and TagDao.system = 0", name)
      try:
        var newTag = newTag(newName)
        db.select(newTag, "TagDao.name = ? and TagDao.system = 0", newName)
        try:
          var oldTagds, newTagds = @[newTagged()]
          db.selectOneToMany(oldTag, oldTagds)
          db.selectOneToMany(newTag, newTagds)
          let newTaggedFiles = newTagds.mapIt it.file.path
          var toUpdate, toDelete = newSeq[Tagged]()
          for tagd in oldTagds:
            if tagd.file.path in newTaggedFiles: toDelete.add tagd
            else:
              tagd.tag = newTag
              toUpdate.add tagd
          db.update toUpdate
          db.delete toDelete
        except: discard
        db.delete(oldTag)
      except:
        oldTag.name = newName
        db.update oldTag
    except: raise newException(ValueError, "Could not find original tag entry!")

proc updateTagDesc*(name, description: string) =
  withMindDb: db.transaction:
    var tag = newTag(name)
    try:
      db.select(tag, "TagDao.name = ? and TagDao.system = 0", tag.name)
      tag.desc = description
      db.update tag
    except: raise newException(ValueError, "Could not find tag entry!")

proc deleteTags*(tagNames: HashSet[string]) =
  var
    tag: TagDao
    tagds: seq[Tagged]

  withMindDb: db.transaction:
    for name in tagNames:
      tag = newTag(name)
      tagds = @[newTagged()]
      try:
        db.select(tag, "TagDao.name = ? and TagDao.system = 0", tag.name)
        db.selectOneToMany(tag, tagds)
      except: discard
      finally:
        db.delete tagds
        db.delete tag

proc readTags*(system = false): seq[string] =
  var tags = @[newTag()]
  withMindDb: db.transaction: db.select(tags, "TagDao.system = ?", system)
  tags.mapIt(it.name & " " & it.desc)
