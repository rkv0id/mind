from std/os import fileExists
from std/sequtils import filterIt
from std/times import DateTime, now

import norm/sqlite
from norm/model import Model
from norm/pragmas import index, uniqueIndex

from ./repository import mindDbFile


type
  File* = ref object of Model
    path* {.uniqueIndex: "File_paths".}: string
    persistent*: bool

  Tag* = ref object of Model
    name* {.uniqueIndex: "Tag_names".}: string
    system*: bool
    desc*: string
  
  FileTag* = ref object of Model
    file* {.index: "FileTag_file".}: File
    tag* {.index: "FileTag_tag".}: Tag
    at*: DateTime

func newFile*(path = "", persistent = false): File =
  File(path: path, persistent: persistent)

func newTag*(name = "", system = false, desc = ""): Tag =
  Tag(name: name, system: system, desc: desc)

func newFileTag*(file = newFile(), tag = newTag(), at = now()): FileTag =
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

proc syncDb*() =
  var
    tags = @[newTag()]
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

    db.rawSelect("""
      SELECT *
      FROM Tag
      LEFT JOIN FileTag ON Tag.id = FileTag.tag
      GROUP BY Tag.id
      HAVING COUNT(FileTag.tag) = 0;""", tags)
    db.delete tags
