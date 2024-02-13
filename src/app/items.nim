
proc newTask*(text: string) = echo "new task: " & text
proc editTask*(id: int, newtext: string) = echo "edit task n." & $id & " to " & newtext
proc subTask*(id: int, parent: int) = echo "sub task n." & $id & " to task n." & $parent
proc doTask*(id: int) = echo "do task n." & $id
proc undoTask*(id: int) = echo "undo task n." & $id
proc delTask*(id: int) = echo "delete task n." & $id
proc newMemo*(text: string) = echo "new memo" & (if text != "nil": ": " & text else: "")
proc openMemo*(id: int) = echo "open memo n." & $id
proc delMemo*(id: int) = echo "delete memo n." & $id