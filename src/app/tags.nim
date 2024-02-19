from std/strutils import join

proc listTags*(tagpattern: string, system: bool, quiet: bool) = echo "show " & (if system: "system" else: "non-system") & " tags."
proc syncTags*(yes: bool) = echo "sync tags" & (if yes: " forcing updates" else: " suggestions") & "."
proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  echo "tag " & (if hard: "(hard copies of)" else: "") & filepattern & " by #" & $tags.join(" #")
proc untagFiles*(filepattern: string, tags: seq[string]) =
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")
proc modTag*(name: string, newname: string) = echo "edit tag #" & name & " to " & newname
proc removeTag*(tag: string, files: seq[string]) =
  if files.len == 0: echo "Removing tag " & tag
  else: echo "untag " & $files & " by #" & tag