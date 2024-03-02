from std/sequtils import mapIt, toSeq
from regex import re2, findAll, group, match

type
  NodeKind = enum
    nkNot, nkAnd, nkOr,
    nkTag, nkSysTag, nkExtension, nkType
  Node = ref object
    case kind: NodeKind
    of nkTag, nkSysTag, nkExtension, nkType: val: string
    of nkNot: op: Node
    of nkAnd, nkOr: leftOp, rightOp: Node


proc tokenize(input: string): seq[string] =
  const matchRgx = re2"(?:s\/|#|\.)[a-zA-Z_]\w*|t\/[a-zA-Z]+|and|or|not|\(|\)(?:\s*\))*"
  const tokenRegx = re2"(s\/|#|\.)[a-zA-Z_]\w*|t\/[a-zA-Z]+|and|or|not|\(|\)"
  echo input.match matchRgx
  if input.match matchRgx:
    input.findAll(tokenRegx).mapIt(input[it.boundaries])
  else: raise newException(ValueError, "Invalid query!")

func parse(tokens: seq[string], operatorStack = newSeq[string](),
           operandStack = newSeq[Node]()): Node =
  # TODO: POPPING
  # STACKING
  # USE A STACK/DEQUEU AND TREAT EDGE CASES (STACKS EMPTINESS)
  case tokens[0]:
  of "not", "and", "or": parse(tokens[1..^1], tokens[0] & operatorStack, operandStack)
  of "(": parse(tokens[1..^1], operatorStack, operandStack)
  of ")": parse(tokens[1..^1], operatorStack, )
  else:
    let operand = case tokens[0][0]:
      of '#': Node(kind: nkTag, val: tokens[0][1..^1])
      of '.': Node(kind: nkExtension, val: tokens[0][1..^1])
      of 's': Node(kind: nkSysTag, val: tokens[0][2..^1])
      of 't': Node(kind: nkType, val: tokens[0][2..^1])
      else: raise newException(ValueError, "Query not-valid. Expected operand but found '" & tokens[0] & "'")
    if operatorStack.len == 0 or operatorStack[0] == "or":
      parse(tokens[1..^1], operatorStack, operand & operandStack)
    else:
      if operatorStack[0] == "not":
        parse(tokens[1..^1], operatorStack[1..^1],
              Node(kind: nkNot, op: operand) & operandStack)
      else:
        parse(tokens[1..^1], operatorStack[1..^1],
              Node(kind: nkAnd, leftOp: operandStack[0], rightOp: operand) & operandStack[1..^1])

proc find*(query: string) =
  ## TODO
  echo tokenize query

find "#bjg or (#E23_fg or ._F) or (not t/G and (t/F or .md and .sormek))"
