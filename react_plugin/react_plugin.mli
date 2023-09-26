module type S = sig
  val render : Router.url option -> React.element
end

val set_module : (module S) -> unit

include S
