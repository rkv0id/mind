from std/with import with
from times import DateTime, now
from options import Option, none, some

from norm/model import Model, cpIgnore
from norm/pragmas import uniqueIndex
from norm/sqlite import transaction,
                        createTables,
                        insert, open

from ./repository import mindDbFile


type
  TaskDao = ref object of Model
    content: string
    done: bool
    doneAt: Option[DateTime]
    parent: Option[TaskDao]
  
  MemoDao = ref object of Model
    title: string
    body: string
    modifiedAt: Option[DateTime]
  
  FileDao = ref object of Model
    path {.uniqueIndex: "File_paths".}: string
    name: string
    hardCopy: bool

  ItemDao = ref object of Model
    addedAt: DateTime
    task: Option[TaskDao]
    memo: Option[MemoDao]
    file: Option[FileDao]
  
  TagDao = ref object of Model
    name {.uniqueIndex: "Tag_names".}: string
    system: bool
  
  TaggedDao = ref object of Model
    item: ItemDao
    tag: TagDao

func newItemDao(addedAt = now(),
                task = none TaskDao,
                memo = none MemoDao,
                file = none FileDao): ItemDao =
  ItemDao(addedAt: addedAt, task: task, memo: memo, file: file)

func newMemoDao(title = "", body = "", modifiedAt = none DateTime): MemoDao =
  MemoDao(title: title, body: body, modifiedAt: modifiedAt)

func newFileDao(path = "", name = "", hardCopy = false): FileDao =
  FileDao(path: path, name: name, hardCopy: hardCopy)

func newTaskDao(content = "",
                done = false,
                doneAt = none DateTime,
                parent = none TaskDao): TaskDao =
  TaskDao(content: content, done: done, doneAt: doneAt, parent: parent)

func newTagDao(name = "", system = false): TagDao =
  TagDao(name: name, system: system)

func newTaggedDao(item = newItemDao(), tag = newTagDao()): TaggedDao =
  TaggedDao(item: item, tag: tag)


let mindDb = "file://" & mindDbFile

proc createSchemas() =
  let dbConn = open(mindDb, "", "", "")
  dbConn.transaction:
    with dbConn:
      createTables newTaggedDao()
      createTables newTaskDao()
      createTables newMemoDao()
      createTables newFileDao()

proc createMemoDao*(addedAt: DateTime, body: string, title: string) =
  var memo = newMemoDao(title, body)
  let dbConn = open(mindDb, "", "", "")
  dbConn.insert(memo, conflictPolicy = cpIgnore)
