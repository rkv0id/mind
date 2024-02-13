
proc listTag*(system: bool) = echo "show " & (if system: "system" else: "non-system") & " tags."
proc editTag*(tag: string, newtag: string) = echo "edit tag #" & tag & " to " & newtag
proc delTag*(tag: string) = echo "delete tag #" & tag
proc tag*(tag: string, files: seq[string], remove: bool, hard: bool) = echo (if remove: "un" else: "") & "tag " & $files & " by #" & tag