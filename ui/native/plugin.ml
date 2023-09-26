open React_plugin

module M : S = struct
  let render url = Shared_native.App.make ~serverUrl:url ()
end

let () = React_plugin.set_module (module M : S)
