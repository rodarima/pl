#!/bin/bash

echo "Compilando..."
make
echo
echo "--------------- P1 --------------"
cat test2.txt | ./p1
echo "------------ Original -----------"
cat -n test2.txt
