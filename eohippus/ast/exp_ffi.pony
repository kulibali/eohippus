use json = "../json"

class val ExpFfi is NodeData
  let identifier: (NodeWith[Identifier] | NodeWith[LiteralString])
  let type_args: (NodeWith[TypeArgs] | None)
  let call_args: NodeWith[CallArgs]
  let partial: Bool

  new val create(
    identifier': (NodeWith[Identifier] | NodeWith[LiteralString]),
    type_args': (NodeWith[TypeArgs] | None),
    call_args': NodeWith[CallArgs],
    partial': Bool)
  =>
    identifier = identifier'
    type_args = type_args'
    call_args = call_args'
    partial = partial'

  fun name(): String => "ExpFfi"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
    match type_args
    | let type_args': NodeWith[TypeArgs] =>
      props.push(("type_args", type_args'.get_json()))
    end
    props.push(("call_args", call_args.get_json()))
    if partial then
      props.push(("partial", partial))
    end