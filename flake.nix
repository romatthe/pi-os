{
  description = "A bare-metal OS kernel for ARMv8 Raspberry Pi boards";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust-nightly = pkgs.rust-bin.nightly."2021-10-10".default.override {
          extensions = [ "llvm-tools-preview" ];
          targets = [ "aarch64-unknown-none-softfloat" ];
        };
        rustfilt = pkgs.rustPlatform.buildRustPackage rec {
          pname = "rustfilt";
          version = "0.2.1";

          src = pkgs.fetchFromGitHub {
            owner = "luser";
            repo = pname;
            rev = version;
            sha256 = "sha256-zb1tkeWmeMq7aM8hWssS/UpvGzGbfsaVYCOKBnAKwiQ=";
          };

          cargoSha256 = "sha256-rs2EWcvTxLVeJ0t+jLM75s+K72t+hqKzwy3oAdCZ8BE=";
        };

      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              rust-nightly
              rustfilt
              cargo-binutils
            ];
          };
        }
    );
}
