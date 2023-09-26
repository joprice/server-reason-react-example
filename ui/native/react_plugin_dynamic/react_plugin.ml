module type S = sig
  val render : Router.url option -> React.element
end

let p = ref None
let set_module m = p := Some m
let get_plugin () : (module S) = match !p with Some s -> s | None -> failwith "No plugin loaded"

let load_plug fname =
  if Sys.file_exists fname then
    try Dynlink.loadfile_private fname with
    | Dynlink.Error err as e ->
        print_endline ("ERROR loading plugin: " ^ Dynlink.error_message err);
        raise e
    | _ -> failwith "Unknown error while loading plugin"
  else failwith "Plugin file does not exist"

let reload () = load_plug "./_build/default/ui/native/shared_native_plugin.cmxs"

let render serverUrl =
  reload ();
  let module M = (val get_plugin () : S) in
  M.render serverUrl
