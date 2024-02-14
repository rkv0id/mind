from std/times import DateTime, now
from std/options import none, some, Option


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
  

proc newMemo(addedAt = now()): Option[int] = some 5
  ## return id of memo if added in db
  