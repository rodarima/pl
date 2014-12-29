#!/bin/bash

./cs < "test.c" > ".indent.pro" 2>/dev/null
indent -v "test-line.c" -o "test-indented.c"
echo "Diferencias entre test.c y test-indented.c"
diff "test.c" "test-indented.c"

