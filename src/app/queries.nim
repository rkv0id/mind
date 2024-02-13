
proc find*(query: string, level: int, file: bool, memo: bool,
          task: bool, done: bool, not_done: bool) =
  echo "show items according to query: " & query & " at a " &
    (if level == 0: "flat" else: $level & "-tree ") & " listing."
  echo not_done
