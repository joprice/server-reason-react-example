{
  description = "Melange starter";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nix-filter
    }:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages."${system}".appendOverlays (import ./nix/overlay.nix { });
      inherit (pkgs) ocamlPackages;
      nodeDependencies = (pkgs.lib.callPackageWith pkgs ./node.nix { nix-filter = nix-filter.lib; }).nodeDependencies;
      serverPkg = system: static:
        let
          pkgs = nixpkgs.legacyPackages."${system}".appendOverlays (
            (import ./nix/overlay.nix { })
          );
          nodeDependencies = (pkgs.lib.callPackageWith pkgs ./node.nix {
            nix-filter = nix-filter.lib;
          }).nodeDependencies;
        in
        (pkgs.callPackage ./nix {
          inherit static;
          nix-filter = nix-filter.lib;
          inherit nodeDependencies;
        }).server;
    in
    rec {
      devShells.default = pkgs.mkShell {
        SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";
        shellHook = ''
          export NODE_PATH=${nodeDependencies}/lib/node_modules
          export PATH="${nodeDependencies}/bin:$PATH"
        '';
        inputsFrom = [ (serverPkg system false) ];
        nativeBuildInputs = [
          pkgs.nodejs
          ocamlPackages.ocaml-lsp
          ocamlPackages.reason
          ocamlPackages.reason-native.refmterr
          ocamlPackages.ocamlformat
          pkgs.bintools
          pkgs.node2nix
          pkgs.watchexec
        ] ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
          ocamlPackages.odoc
        ];
        OCAMLRUNPARAM = "b";
      };
      packages =
        let
          pkgs = nixpkgs.legacyPackages."x86_64-linux".appendOverlays (
            (import ./nix/overlay.nix { })
          );
          nodeDependencies = (pkgs.pkgsCross.musl64.lib.callPackageWith pkgs ./node.nix {
            nix-filter = nix-filter.lib;
          }).nodeDependencies;
          packages = pkgs.callPackage ./nix {
            nix-filter = nix-filter.lib;
            inherit nodeDependencies;
          };
        in
        {
          server = serverPkg system false;
          serverMusl = serverPkg "x86_64-linux" true;
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "server-reason-react-example";
            tag = "0.0.1";
            contents = [
              # this is required for fly ssh to work
              pkgs.dockerTools.fakeNss
              pkgs.pkgsStatic.curl
              pkgs.pkgsCross.musl64.busybox
              pkgs.pkgsStatic.file
            ];
            config = {
              # TODO: fly.io doesn't need this, but local docker and other deployments do
              #Entrypoint = [
              #  "${pkgs.pkgsStatic.tini}/bin/tini"
              #  "--"
              #];
              Entrypoint = [
                "${packages.serverMusl.out}/bin/server"
              ];
              ExposedPorts = {
                "8080/tcp" = { };
              };
              WorkingDir = "/";
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt"
              ];
            };
          };
        };
    }));
}


