import std/[sets, tables]
from std/strutils import join, alignLeft, `%`
from std/sequtils import toSeq, filterIt, foldl, mapIt
from std/os import walkFiles, splitFile, createHardlink, joinPath, absolutePath

from regex import re2, match

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
  ## TODO
  echo "untag " & filepattern & (if tags.len > 0: " by #" & $tags.join(" #") else: "")

proc modTag*(name: string, newname: string) = name.updateTagName newname

proc describeTag*(tag: string, description: string) =
  updateTagDesc(tag, description)

proc removeTag*(tags: seq[string]) = deleteTags tags.toHashSet

proc listTags*(tagpattern: string, system: bool, quiet: bool) =
  let matched =
    if tagpattern == "nil": readTags system
    else: readTags(system).filterIt(it.name.match re2(tagpattern))
  
  if not quiet:
    let tagLen = matched.foldl(max(a, b.name.len), 0)
    echo matched.mapIt("$1\t$2" % [it.name.alignLeft(tagLen), it.desc]).join("\n")
  else: echo matched.mapIt(it.name).join("\n")

proc syncTags*(yes: bool) =
  ## TODO
  echo "sync tags" &
    (if yes: " applying updates" else: " suggestions") & "."

proc find*(query: string, tree: int) =
  ## TODO
  echo "show tagged files according to query: " & query & " at a " &
    (if tree == 0: "flat" else: $tree & "-tree") & " listing."
