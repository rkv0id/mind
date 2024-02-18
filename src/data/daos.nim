from times import DateTime, now
from options import Option, none, some

from norm/model import Model, cpIgnore
from norm/pragmas import uniqueIndex
from norm/sqlite import transaction,
                        createTables,
                        insert, open

from ./repository import mindDbFile


type
  FileDao = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    name: string
    persistent: bool

  TagDao = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
  
  Tagged = ref object of Model
    file: FileDao
    tag: TagDao
    at: DateTime

func newFileDao(path = "", name = "", persistent = false): FileDao =
  FileDao(path: path, name: name, persistent: persistent)

func newTagDao(name = "", system = false): TagDao =
  TagDao(name: name, system: system)

func newTagged(file = newFileDao(), tag = newTagDao(), at = now()): Tagged =
  Tagged(file: file, tag: tag, at: at)


let mindDb = "file://" & mindDbFile

proc createSchemas() =
  let dbConn = open(mindDb, "", "", "")
  dbConn.createTables newTagged()
