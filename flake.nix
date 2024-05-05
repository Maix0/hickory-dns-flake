{
  description = "Flake utils demo";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    hickory-dns-source = {
      flake = false;
      url = "github:hickory-dns/hickory-dns?ref=v0.24.1";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    naersk,
    hickory-dns-source,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        naersk' = pkgs.callPackage naersk {};
        drv = naersk'.buildPackage {
          src = hickory-dns-source;
          name = "hickory-dns";
          version = "0.24.1";
        };
      in {
        packages = rec {
          hickory-dns = drv;
          default = hickory-dns;
        };
        apps = rec {
          hickory-dns = flake-utils.lib.mkApp {drv = self.packages.${system}.hickory-dns;};
          default = hickory-dns;
        };
      }
    );
}
