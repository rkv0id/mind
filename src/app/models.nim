from std/times import DateTime, now
from std/options import none, some, get,
                        Option, isNone
from regex import findAll, re2, group
from std/sequtils import mapIt, toSeq

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
  
func taggedBy(content: string): seq[string] =
  findAll(content, re2"#([a-zA-Z_][a-zA-Z0-9_]+)").toSeq
    .mapIt(content[it.group(0)])

proc newMemo*(body: string, title: Option[string]) =
  createMemoDao(now(), body,
                if title.isNone: title.get
                else: body[0..min(64, high(body))])
  