from std/times import DateTime, now
from std/options import none, some, Option
from std/strutils import isEmptyOrWhitespace

from ../data/daos import createMemoDao

type
  ItemKind {.pure.} = enum
    Task, Memo, File

  Item = object
    id: int
    addedAt : DateTime
    case kind: ItemKind
      of Task:
        content : string
        done = false
        doneAt = none DateTime
      of Memo:
        title: string
        body: string
        modifiedAt = none DateTime
      of File:
        path: string
        hardCopy: bool
  
  Tag = object
    name: string
    system: bool
    items: seq[Item]
  

proc newMemo(title: string, body: string): Item =
  ## return id of memo if added in db
  let addedAt = now()
  let addedId = createMemoDao(title, body, addedAt)
  Item(kind: ItemKind.Memo, id: addedId, addedAt: addedAt,
       title:
         if title.isEmptyOrWhitespace: body[0..min(64, high(body))]
         else: title,
       body: body)
