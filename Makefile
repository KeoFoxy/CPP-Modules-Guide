all:
	clang++ -std=c++20 -fmodules-ts --precompile module1.cppm -o module1.pcm
	clang++ -std=c++20 -fmodules-ts --precompile module2.cppm -o module2.pcm
	clang++ -std=c++20 -fmodules-ts -c module1.pcm -o module1.o
	clang++ -std=c++20 -fmodules-ts -c module2.pcm -o module2.o
	clang++ -std=c++20 -fmodules-ts -fmodule-file=module1.pcm -fmodule-file=module2.pcm -c main.cpp -o main.o
	clang++ -o main main.o module1.o module2.o

