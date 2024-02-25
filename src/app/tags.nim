import std/[sets, tables]
from std/sequtils import toSeq, filterIt, foldl, mapIt
from std/strutils import join, alignLeft, `%`, isEmptyOrWhitespace
from std/os import walkFiles, splitFile, createHardlink, joinPath, absolutePath, fileExists

from regex import re2, match

from ../data/repository import hardFile
from ../data/entities import addTaggedFiles, deleteTags, deleteFiles,
                             updateTagName, updateTagDesc, readTags,
                             deleteTagsFromFiles


proc listTags*(tagpattern: string, all: bool, system: bool, quiet: bool) =
  let
    matched =
      if tagpattern == "nil": readTags system
      else: readTags(system).filterIt(it.name.match re2(tagpattern))
    shown = if all: matched else: matched.filterIt(it.count > 0)
  
  if shown.len > 0:
    if not quiet:
      let tagLen = shown.foldl(max(a, b.name.len), 0)
      echo shown.mapIt("$1\t$2 file(s)\t$3" % [
        it.name.alignLeft(tagLen),
        $it.count,
        it.desc]).join("\n")
    else: echo shown.mapIt(it.name).join("\n")

proc modTag*(name: string, newname: string) =
  if name != newname: name.updateTagName newname

proc describeTag*(tag: string, description: string) =
  updateTagDesc(tag, description)

proc removeTag*(tags: seq[string]) = deleteTags tags.toHashSet

proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  var extensionToPaths: Table[string, seq[string]]
  for path in filepattern.walkFiles.toSeq:
    let
      (_, name, ext) = path.splitFile
      newPath = if hard: hardFile(name & ext) else: path.absolutePath
    if hard:
      if not newPath.fileExists: path.createHardlink newPath
      else: raise newException(ValueError, "A similarly-named file to [" &
                               path & "] exists in Mind data store already!")
    extensionToPaths[ext] = extensionToPaths.getOrDefault(ext, @[]) & newPath
  
  addTaggedFiles(extensionToPaths,
                 tags.filterIt(
                  it.match re2"([a-zA-Z_][a-zA-Z0-9_]+)"
                 ).toHashSet, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  let files = filepattern.walkFiles.toSeq.mapIt it.absolutePath
  if tags.len == 0: deleteFiles files
  else: deleteTagsFromFiles(files, tags.toHashSet)

proc find*(query: string, tree: int, sync: bool) =
  ## TODO
  echo "show tagged files according to query: " & query & " at a " &
    (if tree == 0: "flat" else: $tree & "-tree") & " listing."
