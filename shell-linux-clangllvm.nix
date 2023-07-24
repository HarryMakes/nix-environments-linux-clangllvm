with import <nixpkgs> {};
clangStdenv.mkDerivation {
  name = "linux-clangllvm-nixshell";

/* TODO: Try to manually remove /nix/store/<asterisk>-llvm-binutils-wrapper-<asterisk>/bin/ld.lld from PATH;
   Temporary workaround: `make LD=/nix/store/<asterisk>-llvm-binutils-<asterisk>/bin/ld.lld ...`,
                         where this ld.ldd is symlinked to /nix/store/<asterisk>-lld-<asterisk>/bin/ld.lld */
  shellHook = '' 
    export PATH="$PATH:$HOME/.cargo/bin"
  '';

  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    /* Rust */
    rustup
    /* LLVM/Clang */
    llvm
    llvmPackages.libclang
    llvmPackages.libcxxClang
    llvmPackages.bintools
    /** Ref: https://github.com/ClangBuiltLinux/linux/issues/1877#issuecomment-1626038388 **/
    llvmPackages.bintools-unwrapped
    llvmPackages.clang-unwrapped
    /* menuconfig */
    ncurses
    /* Ref: https://github.com/NixOS/nixpkgs/blob/23.05/pkgs/top-level/linux-kernels.nix#L669 */
    bison flex
    /* Additional pkgs required as reported by `make LLVM=1` error */
    bc
    elfutils
    openssl
    /* add libraries here */
  ];

  /* Ref: https://github.com/NixOS/nixpkgs/issues/52447#issuecomment-853429315 */
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";
}

/* Note: Rust for Linux requires `make LLVM=1 ...` to run any make commands */
