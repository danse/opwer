with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "blog";
    # for cabal to find the header file (zlib.h)
    buildInputs = [ stdenv zlib ];
    # for cabal to find the shared object (zlib.so)
    LD_LIBRARY_PATH = "${zlib}/lib";
  };
}
