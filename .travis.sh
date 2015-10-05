# Install bit Taken from OPAM travis build file: https://github.com/ocaml/opam/blob/ff0fa0f64267da2fa8f6adeb22086ba642eb8d0c/.travis-ci.sh

install_on_linux () {
  # Install OCaml PPAs
  case "$OCAML_VERSION" in
  3.12.1) ppa=avsm/ocaml312+opam12 ;;
  4.00.1) ppa=avsm/ocaml40+opam12 ;;
  4.01.0) ppa=avsm/ocaml41+opam12 ;;
  4.02.3) ppa=avsm/ocaml42+opam12 ;;
  *) echo Unknown $OCAML_VERSION; exit 1 ;;
  esac

  echo "yes" | sudo add-apt-repository ppa:$ppa
  sudo apt-get update -qq
  sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra time $EXTERNAL_SOLVER ${OPAM_TEST:+opam}
}

install_on_osx () {
  curl -OL "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg"
  sudo hdiutil attach XQuartz-2.7.6.dmg
  sudo installer -verbose -pkg /Volumes/XQuartz-2.7.6/XQuartz.pkg -target /
  case "$OCAML_VERSION" in
  4.02.3) brew update; brew install ocaml;;
  4.03.0) brew update; brew install ocaml --HEAD ;;
  *) echo Skipping $OCAML_VERSION on OSX; exit 0 ;;
  esac
  if [ -n "$EXTERNAL_SOLVER$OPAM_TEST" ]; then
      brew install $EXTERNAL_SOLVER ${OPAM_TEST:+opam}
  fi
}

case $TRAVIS_OS_NAME in
osx) install_on_osx ;;
linux) install_on_linux ;;
esac

OCAMLV=$(ocaml -vnum)
echo === OCaml version $OCAMLV ===
if [ "$OCAMLV" != "$OCAML_VERSION" ]; then
    echo "OCaml version doesn't match: travis script needs fixing"
    exit 12
fi

# End OPAM travis extract

make test
