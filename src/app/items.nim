
proc newTask*(text: string) = echo "new task: " & text
proc modifyTask*(id: int, newtext: string) = echo "edit task n." & $id & " to " & newtext
proc subTask*(id: int, parent: int) = echo "sub task n." & $id & " to task n." & $parent
proc doTask*(id: int) = echo "do task n." & $id
proc undoTask*(id: int) = echo "undo task n." & $id
proc removeTask*(id: int) = echo "delete task n." & $id
proc newMemo*(text: string, title: string) = echo "new memo" & (if text != "nil": ": " & text else: "") & (if title != "nil": " with title: " & title else: "")
proc openMemo*(id: int) = echo "open memo n." & $id
proc removeMemo*(id: int) = echo "delete memo n." & $id