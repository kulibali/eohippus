use json = "../json"

class val TypedefMembers is NodeData
  let fields: NodeSeqWith[TypedefField]
  let methods: NodeSeqWith[TypedefMethod]

  new val create(
    fields': NodeSeqWith[TypedefField],
    methods': NodeSeqWith[TypedefMethod])
  =>
    fields = fields'
    methods = methods'

  fun name(): String => "TypedefMembers"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefMembers(
      _child_seq_with[TypedefField](fields, old_children, new_children)?,
      _child_seq_with[TypedefMethod](methods, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if fields.size() > 0 then
      props.push(("fields", Nodes.get_json(fields)))
    end
    if methods.size() > 0 then
      props.push(("methods", Nodes.get_json(methods)))
    end
