{
  description = "rollup-wasm-nix-rust";
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell.url = "github:numtide/devshell/master";
  # Use the same version of nixpkgs as this project.
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.mozilla-overlay.url = "github:mozilla/nixpkgs-mozilla/master";
  inputs.mozilla-overlay.flake = false;

  outputs = { self, nixpkgs, flake-utils, devshell, mozilla-overlay }:
    {
      overlay = import ./overlay.nix;
    }
    //
    (
      flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # Makes the config pure as well. See <nixpkgs>/top-level/impure.nix:
            config = {
              allowBroken = true;
              permittedInsecurePackages = [
                "openssl-1.0.2u"
              ];
            };
            overlays = [
              (import mozilla-overlay)
              devshell.overlay
              self.overlay
            ];
          };
        in
        {
          legacyPackages = pkgs.rollup-wasm-nix-rust;

          defaultPackage = pkgs.rollup-wasm-nix-rust.nix.rust-frontend;

          packages = flake-utils.lib.flattenTree pkgs.rollup-wasm-nix-rust;

          devShell = import ./devshell.nix { inherit pkgs; };

          checks = { };
        }
      )
    );
}
