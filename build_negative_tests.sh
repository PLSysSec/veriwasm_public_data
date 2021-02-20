#build negative tests
nasm negative_tests/negative_tests.S -f elf64 -o negative_tests/negative_tests.o -w-number-overflow
gcc negative_tests/negative_tests.o -o negative_tests/negative_tests.so -nostartfiles -nostdlib -nodefaultlibs -shared
