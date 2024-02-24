import std/[sets, tables]
from std/strutils import join
from std/sequtils import toSeq
from std/os import walkFiles, splitFile, createHardlink, joinPath, absolutePath

from ../data/repository import hardFile
from ../data/entities import addTaggedFiles, updateTagName,
                             deleteTags, updateTagDesc, readTags


proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  var extensionToPaths: Table[string, seq[string]]
  for path in filepattern.walkFiles.toSeq:
    let
      (_, name, ext) = path.splitFile
      newPath = if hard: hardFile(name & ext) else: path.absolutePath
    if hard: path.createHardlink newPath
    extensionToPaths[ext] = extensionToPaths.getOrDefault(ext, @[]) & newPath
  addTaggedFiles(extensionToPaths, tags.toHashSet, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")

proc modTag*(name: string, newname: string) = name.updateTagName newname

proc describeTag*(tag: string, description: string) =
  updateTagDesc(tag, description)

proc removeTag*(tags: seq[string]) = deleteTags tags.toHashSet

proc listTags*(tagpattern: string, system: bool, quiet: bool) =
  echo "show " & (if system: "system" else: "non-system") &
    " tags" & (if quiet: " quitely" else: "") & "."
  echo readTags system

proc syncTags*(yes: bool) =
  echo "sync tags" &
    (if yes: " applying updates" else: " suggestions") & "."

proc find*(query: string, tree: int) =
  echo "show tagged files according to query: " & query & " at a " &
    (if tree == 0: "flat" else: $tree & "-tree") & " listing."
