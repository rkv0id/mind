import std/deques
from std/sequtils import mapIt
from regex import re2, findAll

type
  NodeKind = enum
    nkNot, nkAnd, nkOr,
    nkTag, nkSysTag, nkExtension, nkType
  Node = ref object
    case kind: NodeKind
    of nkTag, nkSysTag, nkExtension, nkType: val: string
    of nkNot: op: Node
    of nkAnd, nkOr: leftOp, rightOp: Node


func parseOr(tokens: var Deque[string]): Node
func parseAtom(tokens: var Deque[string]): Node =
  let token = tokens.popFirst
  case token[0]:
  of '#': result = Node(kind: nkTag, val: token[1..^1])
  of '.': result = Node(kind: nkExtension, val: token[1..^1])
  of 's': result = Node(kind: nkSysTag, val: token[2..^1])
  of 't': result = Node(kind: nkType, val: token[2..^1])
  of '(':
    result = parseOr tokens
    let nextTkn = tokens.peekFirst
    if nextTkn == ")": tokens.popFirst
    else: raise newException(ValueError, "Query parse Error: expected `)` but found `" & nextTkn & "`.")
  else: raise newException(ValueError, "Query parse Error: expected tag atom but found an undefined token `" & token & "`.")

func parseNot(tokens: var Deque[string]): Node =
  if tokens.len > 0:
    if tokens[0] == "not":
      discard tokens.popFirst
      result = Node(kind: nkNot, op: parseAtom tokens)
    else: result = parseAtom tokens
  else: raise newException(ValueError, "Query parse Error: expected `not` or tag atom but hit end of expression.")

func parseAnd(tokens: var Deque[string]): Node =
  result = parseNot tokens
  while tokens.len > 0 and tokens.peekFirst == "and":
    discard tokens.popFirst
    result = Node(kind: nkAnd, leftOp: result, rightOp: parseNot tokens)

func parseOr(tokens: var Deque[string]): Node =
  result = parseAnd tokens
  while tokens.len > 0 and tokens.peekFirst == "or":
    discard tokens.popFirst
    result = Node(kind: nkOr, leftOp: result, rightOp: parseAnd tokens)

func tokenize(input: string): Deque[string] =
  const tokenRegx = re2"(s\/|#|\.)[a-zA-Z_]\w*|t\/[a-zA-Z]+|and|or|not|\(|\)"
  input.findAll(tokenRegx).mapIt(input[it.boundaries]).toDeque

proc parse(input: string): Node =
  var tokens = tokenize input
  parseOr tokens

proc find*(query: string) = echo repr parse query

find "#tag1 and (.md) or (.txt and #tag2 or #tag3) and ((s/systag1 or t/img) and t/file)"
