use "itertools"

use json = "../json"
use ".."

class val Trivia is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      let children' = _info_seq(_children)
      json.Object([
        ("node", "Trivia")
        ("children", children')
      ])
    end

  fun children(): NodeSeq => _children

class val TriviaLineComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TriviaLineComment")
        ("string", recover val String.>concat(start().values(next())) end)
      ])
    end

class val TriviaNestedComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TriviaNestedComment")
        ("string", recover val String.>concat(start().values(next())) end)
      ])
    end

class val TriviaWS is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TriviaWS")
        ("string", recover val String.>concat(start().values(next())) end)
      ])
    end

class val TriviaEOL is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TriviaEOL")
      ])
    end

class val TriviaEOF is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TriviaEOF")
      ])
    end
