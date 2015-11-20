.PHONY: build test deps clean compiletest sample benchmarks
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
test: deps compile compiletest
	./testsuite.native
sample: build
	./main.native -i something.js -n
	cc out.asm
	./a.out
benchmarks: build
	./main.native -i something.js -n
	cc out.asm
	echo "=== Node.js ==="
	time node something.js
	echo "=== Mine ==="
	time ./a.out
