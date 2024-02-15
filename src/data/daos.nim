from std/with import with
from times import DateTime, now
from options import Option, none, some
from std/os import getDataDir, joinPath

from norm/model import Model, cpIgnore
from norm/sqlite import transaction,
                        createTables,
                        insert, open


const MemoedHomeDir = ".memoed"
let
  memoedDataDir* = getDataDir().joinPath(MemoedHomeDir)
  memoedDbFile* = memoedDataDir.joinPath("data.db")
  memoedDb* = "file://" & memoedDbFile

type
  TaskDao = ref object of Model
    content: string
    done: bool
    doneAt: Option[DateTime]
  
  SubOfDao = ref object of Model
    parent: TaskDao
    sub: TaskDao
  
  MemoDao = ref object of Model
    title: string
    body: string
    modifiedAt: Option[DateTime]
  
  FileDao = ref object of Model
    path: string
    name: string
    hardCopy: bool

  ItemDao = ref object of Model
    addedAt: DateTime
    task: Option[TaskDao]
    memo: Option[MemoDao]
    file: Option[FileDao]
  
  TagDao = ref object of Model
    name: string
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

func newTaskDao(content = "", done = false, doneAt = none DateTime): TaskDao =
  TaskDao(content: content, done: done, doneAt: doneAt)

func newSubOfDao(parent = newTaskDao(), sub = newTaskDao()): SubOfDao =
  SubOfDao(parent: parent, sub: sub)

func newTagDao(name = "", system = false): TagDao =
  TagDao(name: name, system: system)

func newTaggedDao(item = newItemDao(), tag = newTagDao()): TaggedDao =
  TaggedDao(item: item, tag: tag)

proc createSchemas() =
  let dbConn = open(memoedDb, "", "", "")
  dbConn.transaction:
    with dbConn:
      createTables newTaggedDao()
      createTables newSubOfDao()

proc createMemoDao*(title: string, body: string, addedAt: DateTime): int64 =
  var memo = newMemoDao(title, body)
  let dbConn = open(memoedDb, "", "", "")
  dbConn.insert(memo, conflictPolicy = cpIgnore)
  result = memo.id
