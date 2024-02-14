
proc find*(query:string, tree: int, file: bool, memo: bool, done: bool, pending: bool) =
  var items = "["
  if file: items &= " files"
  if memo: items &= " memos"
  if done and pending: items &= " tasks"
  elif done: items &= " done-tasks"
  elif pending: items &= " pending-tasks"
  if items == "[" or file and memo and done and pending: items = "all items" else: items &= " ]"
  echo "show " & items & " according to query: " & query & " at a " &
    (if tree == 0: "flat" else: $tree & "-tree") & " listing."
