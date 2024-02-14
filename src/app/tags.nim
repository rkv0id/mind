
proc listTag*(system: bool) = echo "show " & (if system: "system" else: "non-system") & " tags."
proc editTag*(tag: string, newtag: string) = echo "edit tag #" & tag & " to " & newtag
proc delTag*(tag: string) = echo "delete tag #" & tag
proc addTag*(tag: string, files: seq[string], hard: bool) =
  echo "tag " & (if hard: "(hard copies of)" else: "") & $files & " by #" & tag
proc removeTag*(tag: string, files: seq[string]) =
  echo "untag " & $files & " by #" & tag