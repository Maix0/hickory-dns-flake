{
  description = "Flake utils demo";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    crate2nix.url = "github:nix-community/crate2nix";
    hickory-dns-source = {
      flake = false;
      url = "github:hickory-dns/hickory-dns?ref=v0.24.0";
    };
  };
  nixConfig = {
    allow-import-from-derivation = true;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    crate2nix,
    hickory-dns-source,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # pkgs = nixpkgs.legacyPackages.${system};
        c2n = crate2nix.tools.${system};
        cargoNix = c2n.appliedCargoNix {
          name = "hickory-dns-workspace";
          src = hickory-dns-source;
        };
      in {
        packages = rec {
          hickory-dns = cargoNix.workspaceMembers.hickory-dns.build;
          hickory-util = cargoNix.workspaceMembers.hickory-util.build;
          #hello = throw (builtins.toJSON (builtins.attrNames cargoNix.workspaceMembers.hickory-dns));
          default = hickory-dns;
        };
        apps = rec {
          hickory-dns = flake-utils.lib.mkApp {drv = self.packages.${system}.hickory-dns;};
          hickory-util = flake-utils.lib.mkApp {drv = self.packages.${system}.hickory-util;};
          default = hickory-util;
        };
      }
    );
}
