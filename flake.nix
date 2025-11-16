{
  description = "My custom xmonad layout";

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
          my-xmonad = pkgs.haskellPackages.callCabal2nix "my-xmonad" ./. { };
        in
        {
          packages.default = my-xmonad;

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
