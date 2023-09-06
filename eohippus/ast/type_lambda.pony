use "itertools"

use json = "../json"

class val TypeLambda is NodeData
  let bare: Bool
  let cap: (NodeWith[Keyword] | None)
  let identifier: (NodeWith[Identifier] | None)
  let type_params: (NodeWith[TypeParams] | None)
  let param_types: NodeSeqWith[TypeType]
  let return_type: (NodeWith[TypeType] | None)
  let partial: Bool
  let rcap: (NodeWith[Keyword] | None)
  let reph: (NodeWith[Token] | None)

  new val create(
    bare': Bool,
    cap': (NodeWith[Keyword] | None),
    identifier': (NodeWith[Identifier] | None),
    type_params': (NodeWith[TypeParams] | None),
    param_types': NodeSeqWith[TypeType],
    return_type': (NodeWith[TypeType] | None),
    partial': Bool,
    rcap': (NodeWith[Keyword] | None),
    reph': (NodeWith[Token] | None))
  =>
    bare = bare'
    cap = cap'
    identifier = identifier'
    type_params = type_params'
    param_types = param_types'
    return_type = return_type'
    partial = partial'
    rcap = rcap'
    reph = reph'

  fun name(): String => "TypeLambda"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("bare", bare))
    props.push(("partial", partial))
    match cap
    | let cap': Node =>
      props.push(("cap", cap'.get_json()))
    end
    match identifier
    | let identifier': Node =>
      props.push(("identifier", identifier'.get_json()))
    end
    match type_params
    | let type_params': Node =>
      props.push(("type_params", type_params'.get_json()))
    end
    if param_types.size() > 0 then
      props.push(("param_types", Nodes.get_json(param_types)))
    end
    match return_type
    | let return_type': Node =>
      props.push(("return_type", return_type'.get_json()))
    end
    match rcap
    | let rcap': Node =>
      props.push(("rcap", rcap'.get_json()))
    end
    match reph
    | let reph': Node =>
      props.push(("reph", reph'.get_json()))
    end
