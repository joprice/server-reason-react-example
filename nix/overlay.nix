{}:

[
  (self: super: {
    ocamlPackages = super.ocaml-ng.ocamlPackages_5_1;
  })
  (self: super: {
    ocamlPackages =
      super.ocamlPackages.overrideScope'
        (oself: osuper:
          with oself;
          let
            melange = oself.melange;
          in
          {
            server-reason-react = buildDunePackage {
              pname = "server-reason-react";
              version = "n/a";
              src = self.fetchFromGitHub {
                owner = "ml-in-barcelona";
                repo = "server-reason-react";
                rev = "95f94f65a1de63ff4403c750602d0baee074f408";
                sha256 = "sha256-CIMxkElHW6GARt8WKe+mr+G/MNkMfxvP/Q6yI1nFG+M=";
              };
              nativeBuildInputs = [
                reason
                osuper.melange
                reason-native.refmterr
              ];
              propagatedBuildInputs = [
                osuper.melange
                ocaml_pcre
                lwt
                lwt_ppx
              ];
            };
            reason-react-ppx = osuper.reason-react-ppx.overrideAttrs
              (o: {
                src = self.fetchFromGitHub {
                  inherit (o.src) owner repo;
                  rev = "ddcdf980080c40e1cc62635c7505aa80253d5383";
                  sha256 = "sha256-SbwDv6QBDPyjU8yCqpPrpEnvgZprT43JIXk7r9EaZ6g=";
                };
              });
            reason-react = osuper.reason-react.overrideAttrs
              (o: {
                src = self.fetchFromGitHub {
                  inherit (o.src) owner repo;
                  rev = "ddcdf980080c40e1cc62635c7505aa80253d5383";
                  sha256 = "sha256-SbwDv6QBDPyjU8yCqpPrpEnvgZprT43JIXk7r9EaZ6g=";
                };
              });
          });
  })
]
