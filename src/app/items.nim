from std/hashes import hash
from std/options import some, none
from std/times import now, toTime
from std/os import getEnv, execShellCmd
from std/strutils import isEmptyOrWhitespace

from docopt import Value, ValueKind

from ./models import newMemo
from ../data/repository import memoFile


proc newMemo*(title: Value) =
  let
    filename = "MEMO-" & $hash(now().toTime()) & ".memo"
    filepath = memoFile(filename)
    defaultEditor = getEnv("EDITOR")

  var memoBody = ""
  while true:
    discard execShellCmd(defaultEditor & " " & filepath)
    let file = open(filepath)
    defer: file.close()
    memoBody = readAll(file)

    if memoBody.len in 0..512:
      if memoBody.isEmptyOrWhitespace:
        echo "Memo is empty! No memo was created."
        return
      break
    else: echo """
Please limit yourself to 512 characters in a memo.
You might also consider creating a separate file and tagging it instead!
"""

  newMemo(memoBody,
          if title.kind == ValueKind.vkNone: none string
          else: some $title)

proc openMemo*(id: int) = echo "open memo n." & $id
proc removeMemo*(id: int) = echo "delete memo n." & $id
proc newTask*(text: string) = echo "new task: " & text
proc modifyTask*(id: int, newtext: string) = echo "edit task n." & $id & " to " & newtext
proc subTask*(id: int, parent: int) = echo "sub task n." & $id & " to task n." & $parent
proc doTask*(id: int) = echo "do task n." & $id
proc undoTask*(id: int) = echo "undo task n." & $id
proc removeTask*(id: int) = echo "delete task n." & $id
