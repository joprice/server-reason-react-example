open Piaf
open Result_syntax
open Eio.Std

type mode = Hx | HxSwap | Server

let query_param uri param =
  match Uri.query uri |> List.assoc_opt param with Some [ param ] -> Some param | _ -> None

let send_raw_html ?(headers = []) ?(status = `OK) body =
  let headers =
    Headers.(of_list ([ (Well_known.content_type, "text/html; charset=utf-8") ] @ headers))
  in
  Response.of_string ~headers ~body status

let piaf_config = { Piaf.Config.default with follow_redirects = true }

let get env ~headers ~sw url =
  (* TODO: curl-style debug logging *)
  let result =
    let* response = Client.Oneshot.get ~headers ~config:piaf_config ~sw env (Uri.of_string url) in
    let body = Body.to_string response.body in
    if Status.is_successful response.status then body
    else
      let* body = body in
      let message = Status.to_string response.status in
      Error (`Msg (Format.sprintf "%s %s" message body))
  in
  result |> Result.map_error Error.to_string

let post env ~body ~headers ~sw url =
  (* TODO: curl-style debug logging *)
  let result =
    let* response =
      Client.Oneshot.post ~headers ~body ~config:piaf_config ~sw env (Uri.of_string url)
    in
    let body = Body.to_string response.body in
    if Status.is_successful response.status then body
    else
      let* body = body in
      let message = Status.to_string response.status in
      Error (`Msg (Format.sprintf "%s %s" message body))
  in
  result |> Result.map_error Error.to_string

let parse_form_body ctx =
  let result =
    let+ body = ctx.Piaf.Server.request.body |> Body.to_string in
    body |> String.split_on_char '&'
    |> List.filter_map (fun pair ->
           match pair |> String.split_on_char '=' with
           | [ key; value ] ->
               let key = Uri.pct_decode key in
               let value = Uri.pct_decode value in
               Some (key, value)
           | parts ->
               traceln "Ignoring invalid param %s" (String.concat "," parts);
               None)
  in
  result |> Result.map_error (Fmt.to_to_string Piaf.Error.pp_hum)

let form_field field params =
  params |> List.assoc_opt field |> Option.to_result ~none:(Format.sprintf "Missing %s field" field)

let handle_error result =
  result
  |> Result.fold ~ok:Fun.id ~error:(fun error ->
         traceln "Failed handling request %s" error;
         Piaf.Response.create `Internal_server_error)
