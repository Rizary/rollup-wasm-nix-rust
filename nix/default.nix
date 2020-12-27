{ pkgs }: rec
{
  rust-overlay = pkgs.callPackage ./rust-overlay { };
  rust-frontend = pkgs.callPackage ./rust-frontend { };
}
