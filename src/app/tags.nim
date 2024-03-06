from std/sets import toHashSet, items
from std/os import walkFiles, absolutePath
from std/strutils import `%`, join, alignLeft
from std/sequtils import toSeq, filterIt, foldl, mapIt

from regex import re2, match

from ../data/entities import addTaggedFiles, deleteTags, deleteFiles,
                             updateTagName, updateTagDesc, readTags,
                             deleteTagsFromFiles


proc listTags*(tagpattern: string, all, system, quiet: bool) =
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

proc tagFiles*(filepattern: string, tags: seq[string], hard: bool) =
  addTaggedFiles(filepattern.walkFiles.toSeq,
                 tags.filterIt(
                  it.match re2"([a-zA-Z_]\w*)"
                 ).toHashSet.toSeq, hard)

proc untagFiles*(filepattern: string, tags: seq[string]) =
  let files = filepattern.walkFiles.toSeq.mapIt it.absolutePath
  if tags.len == 0: deleteFiles files
  else: deleteTagsFromFiles(files, tags.toHashSet.toSeq)

proc modTag*(name, newname: string) =
  if name != newname: name.updateTagName newname

proc describeTag*(tag, description: string) = updateTagDesc(tag, description)
proc removeTag*(tags: seq[string]) = deleteTags tags.toHashSet.toSeq
