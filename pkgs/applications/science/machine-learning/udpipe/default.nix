{ lib
, stdenv
, fetchgit
}:

let udpipe = stdenv.mkDerivation rec {
  pname = "udpipe";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ufal";
    repo = "udpipe";
    rev = "v${version}";
    sha256 = "1mpcpl9a57z0g42pn5w54v4cmxc2q63hblsyqphbp6hzhga6ngcl";
  };

  sourceRoot = "${src.name}/src";

  enableParallelBuilding = true;

  buildPhase = ''
    make MODE=release -j$NIX_BUILD_CORES exe server lib
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -v udpipe $out/bin
    cp -v rest_server/udpipe_server $out/bin
    cp -v libudpipe.a $out/lib/
  '';

  doCheck = true;

  passthru.tests.minimal = runCommand "${pname}-test" {
      buildInputs = [
        udpipe
        dieHook
      ];
    } ''
      cd tests && make
    '';

  meta = with lib; {
    homepage = "https://github.com/ufal/udpipe";
    description = " UDPipe: Trainable pipeline for tokenizing, tagging, lemmatizing and parsing Universal Treebanks and other CoNLL-U files";
    maintainers = with maintainers; [ unhammer ];
    license = licenses.mpl20;
    platforms = platforms.all;
  };
};

in
  udpipe
