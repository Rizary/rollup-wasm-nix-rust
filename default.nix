{ system ? builtins.currentSystem }:
let
  nodeDependencies = (pkgs.callPackage ./compose.nix {}).shell.nodeDependencies;
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  pkgs = import <nixpkgs> { inherit system; overlays = [ moz_overlay ]; };
  rust-overlay = (pkgs.rustChannelOf {
    rustToolchain = ./rust-toolchain;
    sha256 = "sha256-7zt+rHZxx+ha4P/UnT2aNIuBtjPkejVI2PycAt+Apiw=";
  }).rust.override {
    extensions = [
      "clippy-preview"
      "rls-preview"
      "rustfmt-preview"
      "rust-analysis"
      "rust-std"
      "rust-src"
    ];
    targets = [ "wasm32-unknown-unknown" ];
  };
in
with pkgs;
stdenv.mkDerivation {
  name = "rollup-wasm-nix";
  src = ./.;
  buildInputs = [ nodejs nodeDependencies rust-overlay openssl zlib cacert ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    mkdir -p $out
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
    node ${nodeDependencies}/lib/node_modules/wasm-pack/install.js

    ls -lahg ${rust-overlay}/

    ${rust-overlay}/bin/cargo check

    # Build the distribution bundle in
    npm run build

  '';

  installPhase = ''
    mkdir -p $out
    ls -lhag
    cp -r js $out/
  '';
}