{ pkgs, rollup-wasm-nix-rust }:
let
  inherit (pkgs) stdenv lib;

  package = lib.importJSON ../../package.json;

  # postcssConf = callPackage ./postcssConf.nix { };

  yarnPkg = pkgs.mkYarnPackage rec {
    pname = package.name;
    version = package.version;
    src = null;
    dontUnpack = true;
    packageJSON = ../../package.json;
    yarnLock = ../../yarn.lock;

    preConfigure = ''
      mkdir ${package.name}
      cd ${package.name}
      ln -s ${packageJSON} ./package.json
      ln -s ${yarnLock} ./yarn.lock
    '';

    yarnPreBuild = ''
      mkdir -p $HOME/.node-gyp/${pkgs.nodejs.version}
      echo 9 > $HOME/.node-gyp/${pkgs.nodejs.version}/installVersion
      ln -sfv ${pkgs.nodejs}/include $HOME/.node-gyp/${pkgs.nodejs.version}
    '';

    pkgConfig = {
    };

    publishBinsFor = [
      "rollup"
    ];
  };
in
stdenv.mkDerivation {
  name = "${package.name}-${package.version}";

  src = lib.cleanSourceWith {
    filter = name: type:
      !(lib.hasSuffix ".css" name) &&
      !(lib.hasSuffix ".html" name) &&
      !(lib.hasSuffix ".log" name) &&
      !(lib.hasSuffix ".nix" name) &&
      !(lib.hasSuffix "node_modules" name)
    ;
    src = ../../.;
  };

  buildInputs = [ pkgs.nodejs-14_x yarnPkg pkgs.yarn rollup-wasm-nix-rust.nix.rust-overlay pkgs.openssl pkgs.zlib pkgs.cacert ];

  patchPhase = ''
    ln -s ${yarnPkg}/libexec/${package.name}/node_modules .
  '';

  buildPhase = ''
    # Yarn writes cache directories etc to $HOME.
    export HOME=$PWD/yarn_home
    export PATH=$PWD/node_modules/.bin:$PATH
    node node_modules/wasm-pack/install.js
    yarn --enable-pnp --offline build
  '';

  installPhase = ''
    mkdir -p $out/js
    cp -r devhtml/. $out/
    cp -r dist/. $out/js
  '';

  shellHook = ''
    rm -rf node_modules
    ln -sv ${yarnPkg}/libexec/${package.name}/node_modules .
    export PATH=$PWD/node_modules/.bin:$PATH
  '';
}