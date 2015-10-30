#!/bin/bash

for f in *.js
do
  ../main.native -i $f -o ./out.asm
  cc ./out.asm
  ./a.out | read var
  if [ "$var.js" != $f ]; then
    echo "$f failed $var.js"
    exit 1
  fi
done
