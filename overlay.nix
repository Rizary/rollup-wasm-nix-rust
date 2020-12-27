final: prev:
{
  rollup-wasm-nix-rust = rec {
    nix = prev.callPackage ./nix { };
  };
}
