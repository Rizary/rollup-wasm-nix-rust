{ pkgs }:

with pkgs;

# Configure your development environment.
#
# Documentation: https://github.com/numtide/devshell
mkDevShell {
  name = "rollup-wasm-nix-rust";
  motd = ''
    Welcome to the pkgs.rollup-wasm-nix-rust application.
  '';
  commands = [
  ];

  bash = {
    extra = ''
      export LD_INCLUDE_PATH="$DEVSHELL_DIR/include"
      export LD_LIB_PATH="$DEVSHELL_DIR/lib"
    '';
    interactive = '''';
  };

  env = {
    OPENSSL_DIR = "${openssl.bin}/bin";
    OPENSSL_LIB_DIR = "${openssl.out}/lib";
    OPENSSL_INCLUDE_DIR = "${openssl.out.dev}/include";
  };

  packages = [
    # build tools
    ## Rust
    rollup-wasm-nix-rust.nix.rust-overlay

    ### Others
    binutils
    pkgconfig
    openssl
    openssl.dev
    gcc
    glibc
    gmp.dev
    nixpkgs-fmt

    # Javascript related frontend
    # It is also used for Rust's frontend development
    nodejs-14_x
    yarn
    yarn2nix
  ];
}
