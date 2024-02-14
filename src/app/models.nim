from std/times import DateTime, now
from std/options import none

type
  ItemKind {.pure.} = enum
    Task, Memo, File

  Item = object
    id: int
    createdAt = now()
    case kind: ItemKind
      of Task:
        content : string
        done = false
        doneAt = none DateTime
      of Memo:
        title: string
        content: string
        modifiedAt = none DateTime
      of File:
        path: string
        hardCopy: bool
  