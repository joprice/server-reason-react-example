open Eio.Std
open Routes

type 'a router = {
  get : 'a Routes.router;
  post : 'a Routes.router;
  delete : 'a Routes.router;
  put : 'a Routes.router;
}

(* taken from https://github.com/jchavarri/ocaml_webapp/blob/0a4f91dd10f82e2bc6665755bc2820c90a3027de/shared/method_routes.ml#L30 *)
let one_of routes =
  let routes = List.rev routes in
  let get, post, delete, put =
    List.fold_left
      (fun (get, post, delete, put) (meth, route) ->
        match meth with
        | `DELETE -> (get, post, route :: delete, put)
        | `GET -> (route :: get, post, delete, put)
        | `POST -> (get, route :: post, delete, put)
        | `PUT -> (get, post, delete, route :: put))
      ([], [], [], []) routes
  in
  Routes.{ get = one_of get; post = one_of post; delete = one_of delete; put = one_of put }

let match' ~meth ~target { get; post; delete; put } =
  match meth with
  | `GET -> Routes.match' ~target get
  | `POST -> Routes.match' ~target post
  | `DELETE -> Routes.match' ~target delete
  | `PUT -> Routes.match' ~target put
  | _ -> Routes.NoMatch

(* TODO: capture auth even on 404 *)
let unwrap_result = function
  | NoMatch -> fun _ _ -> Piaf.Response.of_string ~body:"" `Not_found
  | FullMatch r | MatchWithTrailingSlash r -> r

let method_name = function
  | `CONNECT -> "CONNECT"
  | `DELETE -> "DELETE"
  | `GET -> "GET"
  | `HEAD -> "HEAD"
  | `OPTIONS -> "OPTIONS"
  | `Other other -> other
  | `POST -> "POST"
  | `PUT -> "PUT"
  | `TRACE -> "TRACE"

let route ~meth ~target routes =
  traceln "[%s] %s" (method_name meth) target;
  unwrap_result @@ match' ~meth ~target routes
