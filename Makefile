.PHONY: build test deps clean compiletest
.DEFAULT_GOAL := build
clean:
	rm -rf _build
	rm -f main.native
	rm -f testsuite.native
deps:
	opam install -y `cat dependencies.txt | xargs`
compile:
	ocamlbuild -use-menhir -use-ocamlfind -I src/ ./main.native
compiletest:
	ocamlbuild -use-menhir -use-ocamlfind -I src/ -I test/ ./testsuite.native
build: deps compile
test: deps compiletest
	./testsuite.native
