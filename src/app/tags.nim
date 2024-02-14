
proc listTag*(system: bool) = echo "show " & (if system: "system" else: "non-system") & " tags."
proc modifyTag*(tag: string, newtag: string) = echo "edit tag #" & tag & " to " & newtag
proc addTag*(tag: string, files: seq[string], hard: bool) =
  echo "tag " & (if hard: "(hard copies of)" else: "") & $files & " by #" & tag
proc removeTag*(tag: string, files: seq[string]) =
  if files.len == 0: echo "Removing tag " & tag
  else: echo "untag " & $files & " by #" & tag