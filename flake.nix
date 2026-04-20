{
  description = "NJU Digital Experiment - Verilog digital logic design with Verilator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          coreutils
          findutils
          verilator
          gnumake
          gcc
          SDL2
          SDL2.dev
          SDL2_image
          SDL2_ttf
          (python3.withPackages (p: [ p.pillow ]))
        ];

        shellHook = ''
          export NVBOARD_HOME="$PWD/nvboard"

          mkdir -p /tmp/nju-digital-exp-bin
          cat > /tmp/nju-digital-exp-bin/sdl2-config << 'SDL2WRAPPER'
#!/bin/sh
case "$1" in
    --cflags) pkg-config --cflags sdl2 SDL2_image SDL2_ttf ;;
    --libs) pkg-config --libs sdl2 SDL2_image SDL2_ttf ;;
    --prefix) pkg-config --variable=prefix sdl2 ;;
    --version) pkg-config --modversion sdl2 ;;
    *) echo "" ;;
esac
SDL2WRAPPER
          chmod +x /tmp/nju-digital-exp-bin/sdl2-config
          export PATH="/tmp/nju-digital-exp-bin:$PATH"
        '';
      };
    };
}
