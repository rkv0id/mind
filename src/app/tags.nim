import std/tables
from std/strutils import join
from std/sequtils import toSeq
from std/os import walkFiles, splitFile, createHardlink, joinPath

from ../data/daos import createFiles
from ../data/repository import hardFile


proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  var extensionToPaths: Table[string, seq[string]]
  for path in filepattern.walkFiles.toSeq:
    let
      (_, name, ext) = path.splitFile
      newPath = if hard: hardFile(name & ext) else: path
    if hard: path.createHardlink newPath
    extensionToPaths[ext] = extensionToPaths.getOrDefault(ext, @[]) & newPath
  createFiles(extensionToPaths, tags, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")

proc modTag*(name: string, newname: string) = echo "edit tag #" & name & " to " & newname

proc removeTag*(tag: string, files: seq[string]) =
  if files.len == 0: echo "Removing tag " & tag
  else: echo "untag " & $files & " by #" & tag

proc listTags*(tagpattern: string, system: bool, quiet: bool) =
  echo "show " & (if system: "system" else: "non-system") &
    " tags" & (if quiet: " quitely" else: "") & "."

proc syncTags*(yes: bool) =
  echo "sync tags" &
    (if yes: " applying updates" else: " suggestions") & "."
