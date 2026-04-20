{
  description = "NJU Digital Experiment - Verilog digital logic design with Verilator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      fhs = pkgs.buildFHSEnv {
        name = "nju-digital-exp";
        targetPkgs = pkgs: with pkgs; [
          coreutils
          findutils
          verilator
          gnumake
          gcc
          SDL2
          SDL2.dev
          SDL2_image
          SDL2_ttf
          python3
          pkg-config
        ];
        runScript = "bash";
        profile = ''
          export NVBOARD_HOME="$PWD/nvboard"

          mkdir -p /tmp/sdl2-fix
          cat > /tmp/sdl2-fix/sdl2-config << 'WRAPPER'
#!/bin/sh
case "$1" in
  --cflags) echo "-I/usr/include/SDL2 -D_GNU_SOURCE=1 -D_REENTRANT" ;;
  --libs) echo "-L/usr/lib -lSDL2" ;;
  --prefix) echo "/usr" ;;
  --version) echo "2.32.64" ;;
  *) echo "Usage: $0 [--prefix] [--version] [--cflags] [--libs]" >&2 ;;
esac
WRAPPER
          chmod +x /tmp/sdl2-fix/sdl2-config
          export PATH="/tmp/sdl2-fix:$PATH"
        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ fhs ];
        shellHook = ''
          exec ${fhs}/bin/nju-digital-exp
        '';
      };
    };
}
