import std/tables
from std/times import DateTime, now
from std/options import Option, none, some

import norm/sqlite
from norm/model import Model, cpIgnore
from norm/pragmas import uniqueGroup, uniqueIndex

from ./repository import mindDbFile


type
  FileDao = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    persistent: bool

  TagDao = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
  
  Tagged = ref object of Model
    file {.uniqueGroup.}: FileDao
    tag {.uniqueGroup.}: TagDao
    at: DateTime

func newFile(path = "", persistent = false): FileDao =
  FileDao(path: path, persistent: persistent)

func newTag(name = "", system = false): TagDao =
  TagDao(name: name, system: system)

func newTagged(file = newFile(), tag = newTag(), at = now()): Tagged =
  Tagged(file: file, tag: tag, at: at)


let mindDb = "file://" & mindDbFile

proc createSchemas() =
  let dbConn = open(mindDb, "", "", "")
  dbConn.createTables newTagged()

proc addTaggedFiles*(extensionToPaths: Table[string, seq[string]],
                     tagNames = newSeq[string](), persistent = false) =
  let dbConn = open(mindDb, "", "", "")
  var
    tagged = newTagged()
    sysTag = newTag(system=true)
    file = newFile(persistent=persistent)
    tags: seq[TagDao]
  
  dbConn.transaction:
    for name in tagNames:
      var userTag = newTag(name)
      try: dbConn.select(userTag, "TagDao.name = ? and TagDao.system = 0", name)
      except: dbConn.insert(userTag, conflictPolicy=cpIgnore)
      tags.add userTag

    for ext in extensionToPaths.keys:
      sysTag.name = ext
      try: dbConn.select(sysTag, "TagDao.name = ? and TagDao.system = 1", ext)
      except: dbConn.insert(sysTag, conflictPolicy=cpIgnore)
      for path in extensionToPaths[ext]:
        file.path = path
        try: dbConn.select(file, "FileDao.path = ?", path)
        except:
          dbConn.insert(file, conflictPolicy=cpIgnore)
          tagged.tag = sysTag
          tagged.file = file
          dbConn.insert(tagged, conflictPolicy=cpIgnore)
        for tag in tags:
          tagged.tag = tag
          dbConn.insert(tagged, conflictPolicy=cpIgnore)

proc updateTagName*(name, newName: string) =
  let dbConn = open(mindDb, "", "", "")

  dbConn.transaction:
    try:
      var oldTag = newTag(name)
      dbConn.select(oldTag, "TagDao.name = ? and TagDao.system = 0", name)
      try:
        var newTag = newTag(newName)
        dbConn.select(newTag, "TagDao.name = ? and TagDao.system = 0", newName)
        try:
          var tagds = @[newTagged(tag=oldTag)]
          dbConn.select(tagds, "Tagged.tag = ?", oldTag)
          for tagged in tagds: tagged.tag = newTag
          dbConn.update tagds
        except: discard
        dbConn.delete(oldTag)
      except:
        oldTag.name = newName
        dbConn.update oldTag
    except: raise newException(ValueError, "Original tag doesn't exist!")
