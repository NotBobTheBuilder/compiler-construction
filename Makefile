.PHONY: build test deps clean compiletest sample
.DEFAULT_GOAL := build
clean:
	rm -rf _build
	rm -f main.native
	rm -f testsuite.native
deps:
	opam install -y `cat dependencies.txt | xargs`
compile:
	ocamlbuild -use-menhir -use-ocamlfind -I src/ ./src/main.native
compiletest:
	ocamlbuild -use-menhir -use-ocamlfind -I src/ -I test/ ./test/testsuite.native
build: deps compile
test: deps compiletest
	./testsuite.native
sample: build
	./main.native -i something.js
	cc out.asm
	./a.out
