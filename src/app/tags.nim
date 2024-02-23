import std/tables
from std/sequtils import toSeq
from std/strutils import join, isEmptyOrWhitespace
from std/os import walkFiles, splitFile, createHardlink, joinPath

from ../data/repository import hardFile
from ../data/daos import addTaggedFiles, updateTagName


proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  var extensionToPaths: Table[string, seq[string]]
  for path in filepattern.walkFiles.toSeq:
    let
      splitHolder = path.splitFile
      name = splitHolder.name
      ext = "sys[" & splitHolder.ext & "]"
      newPath = if hard: hardFile(name & splitHolder.ext) else: path
    if hard: path.createHardlink newPath
    extensionToPaths[ext] = extensionToPaths.getOrDefault(ext, @[]) & newPath
  addTaggedFiles(extensionToPaths, tags, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")

proc modTag*(name: string, newname: string) = name.updateTagName newname

proc removeTag*(tags: seq[string]) = echo "Removing tags " & tags

proc listTags*(tagpattern: string, system: bool, quiet: bool) =
  echo "show " & (if system: "system" else: "non-system") &
    " tags" & (if quiet: " quitely" else: "") & "."

proc syncTags*(yes: bool) =
  echo "sync tags" &
    (if yes: " applying updates" else: " suggestions") & "."
