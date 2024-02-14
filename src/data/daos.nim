from std/with import with
from options import Option, none
from times import DateTime, now
from std/os import getDataDir, joinPath

from norm/model import Model
from norm/sqlite import open, createTables

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

func newMemoDao(title: string,
                body: string,
                modifiedAt = none DateTime): MemoDao =
  MemoDao(title: title, body: body, modifiedAt: modifiedAt)

func newFileDao(path: string,
                name = "",
                hardCopy = false): FileDao =
  FileDao(path: path, name: name, hardCopy: hardCopy)

func newTaskDao(content: string,
                done = false,
                doneAt = none DateTime): TaskDao =
  TaskDao(content: content, done: done, doneAt: doneAt)

func newSubOfDao(parent: TaskDao, sub: TaskDao): SubOfDao =
  SubOfDao(parent: parent, sub: sub)

func newTagDao(name: string, system = false): TagDao =
  TagDao(name: name, system: system)

func newTaggedDao(item: ItemDao, tag: TagDao): TaggedDao =
  TaggedDao(item: item, tag: tag)

proc createSchemas() =
  with open(memoedDb, "", "", ""):
    createTables newItemDao()