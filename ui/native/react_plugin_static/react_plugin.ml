module type S = sig
  val render : Router.url option -> React.element
end

let render serverUrl = Shared_native.App.make ~serverUrl ()
let set_module _ = ()
