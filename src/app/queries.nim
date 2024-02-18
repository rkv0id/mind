
proc find*(query:string, tree: int) =
  echo "show tagged files according to query: " & query & " at a " &
    (if tree == 0: "flat" else: $tree & "-tree") & " listing."
