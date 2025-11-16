{
  description = "Custom layouts to extend xmonad";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          pkgs,
          ...
        }:
        let
          xmonad-jc-extra = pkgs.haskellPackages.callCabal2nix "xmonad-jc-extra" ./. { };
        in
        {
          packages.default = xmonad-jc-extra;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              haskellPackages.ghc
              haskellPackages.haskell-language-server
              haskellPackages.cabal-install
              haskellPackages.cabal-gild
              haskellPackages.fourmolu
              haskellPackages.hlint

              # Needed to compile xmonad
              xorg.libX11.dev
              xorg.libXrandr
              xorg.libXScrnSaver
              xorg.libXext
            ];
          };
        };
    };
}
