{
  description = "Nix flake for my fork of dwm";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }: {
        systems = nixpkgs.lib.systems.flakeExposed;

        perSystem = { pkgs, self', ... }: {
          packages.dwm = pkgs.stdenv.mkDerivation {
            pname = "dwm";
            version = "6.8";

            src = ./.;

            nativeBuildInputs = [ pkgs.pkg-config ];

            buildInputs = with pkgs; [
              libx11
              libxinerama
              libxft
              fontconfig
              freetype
            ];

            makeFlags = [
              "CC=${pkgs.stdenv.cc.targetPrefix}cc"
              "PREFIX=$(out)"
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
              "FREETYPEINC=${pkgs.freetype.dev}/include/freetype2"
            ];

            meta = {
              description = "Dynamic window manager for X (flexipatch build)";
              homepage = "https://github.com/sh4k095/dwm-flexipatch";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.unix;
              mainProgram = "dwm";
            };
          };

          packages.default = self'.packages.dwm;

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.packages.dwm ];

            MAKEFLAGS = toString [
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
              "FREETYPEINC=${pkgs.freetype.dev}/include/freetype2"
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
      }
    );
}
