import std/[sets, tables]
from std/sequtils import toSeq
from std/strutils import join, isEmptyOrWhitespace
from std/os import walkFiles, splitFile, createHardlink, joinPath

from ../data/repository import hardFile
from ../data/daos import addTaggedFiles, updateTagName,
                         deleteTags, updateTagDesc,
                         readTags


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
  addTaggedFiles(extensionToPaths, tags.toHashSet, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")

proc modTag*(name: string, newname: string) = name.updateTagName newname

proc describeTag*(tag: string, description: string) = discard

proc removeTag*(tags: seq[string]) = deleteTags tags.toHashSet

proc listTags*(tagpattern: string, system: bool, quiet: bool) =
  echo "show " & (if system: "system" else: "non-system") &
    " tags" & (if quiet: " quitely" else: "") & "."
  echo readTags system

proc syncTags*(yes: bool) =
  echo "sync tags" &
    (if yes: " applying updates" else: " suggestions") & "."
