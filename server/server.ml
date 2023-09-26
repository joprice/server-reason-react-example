open Eio.Std

let routes () =
  let open Routes in
  Router.one_of
    [
      ( `GET,
        route wildcard (fun _ req env ->
            React_app.render env ~url:req.Piaf.Server.request.target |> Http.send_raw_html) );
    ]

let start env =
  let connection_handler (req : Piaf.Request_info.t Piaf.Server.ctx) =
    try Router.route ~meth:req.request.meth ~target:req.request.target (routes ()) req env
    with error ->
      traceln "Failed handling request %s\n%s" (Printexc.to_string error)
        (Printexc.get_backtrace ());
      Piaf.Response.of_string ~body:"" `Internal_server_error
  in
  let recommended_domain_count = Domain.recommended_domain_count () in
  let host = Eio.Net.Ipaddr.V4.any and port = 8080 in
  Switch.run (fun sw ->
      let config =
        Piaf.Server.Config.create ~buffer_size:0x1000 ~domains:recommended_domain_count
          (`Tcp (host, port))
      in
      let server = Piaf.Server.create ~config connection_handler in
      ignore (Piaf.Server.Command.start ~sw env server : Piaf.Server.Command.t))
