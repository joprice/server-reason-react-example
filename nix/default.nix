{ pkgs, nodeDependencies, nix-filter, static }:
with pkgs;
with (if static then pkgs.pkgsCross.musl64.ocamlPackages else ocamlPackages);
let
  genSrc = { dirs, files }:
    with nix-filter; filter {
      root = ./..;
      include = [ "dune" "dune-project" ] ++ files ++ (builtins.map inDirectory dirs);
    };
in
{
  server = buildDunePackage {
    version = "0.0.1";
    pname = "server";
    src = genSrc {
      dirs = [ "server" "ui" "react_plugin" "react_compat" ];
      files = [ "server-reason-react-example.opam" ];
    };
    # This avoids accidentally pulling in the full node dependencies graph, which can happen 
    # if a build is not run in prod mode, resulting in a very large closure.
    disallowedReferences = [ nodeDependencies ];
    buildPhase = ''
      runHook preBuild
      export NODE_PATH=${nodeDependencies}/lib/node_modules
      export ES_MINIFY="--minify"
      export PATH="${nodeDependencies}/bin:$PATH"
      dune build server/server_prod.exe ''${enableParallelBuild:+-j $NIX_BUILD_CORES} --profile=${if static then "static" else "release"}
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp _build/default/server/server_prod.exe $out/bin/server
      runHook postInstall
    '';
    nativeBuildInputs = [
      dune-configurator
      pkgs.ocamlPackages.melange
      pkg-config
      tailwindcss
      dune_3
      utop
    ];
    buildInputs = [
      eio
      eio_main
      eio_posix
      piaf
      fmt
      logs-ppx
      routes
      ptime
      server-reason-react
      reason-react
      reason-react-ppx
      melange-webapi
    ];
  };
}
