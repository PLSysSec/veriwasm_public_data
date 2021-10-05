#build negative tests
nasm negative_tests/negative_tests.S -f elf64 -o negative_tests/negative_tests.o -w-number-overflow
gcc negative_tests/negative_tests.o -o negative_tests/negative_tests.so -nostartfiles -nostdlib -nodefaultlibs -shared
# Build negative tests for zerocost checker
nasm negative_tests/negative_tests_locals.S -f elf64 -o negative_tests/negative_tests_locals.o -w-number-overflow
gcc negative_tests/negative_tests_locals.o -o negative_tests/negative_tests_locals.so -nostartfiles -nostdlib -nodefaultlibs -shared
