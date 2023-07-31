# CPP Modules compilation

## Preferences

```bash
MacOS Ventura 13.2
Version 14.3.1 (14E300c)


Apple clang version 14.0.3 (clang-1403.0.22.14.1)
Target: arm64-apple-darwin22.3.0
Thread model: posix

cmake version 3.26.0
```

Example contains two modules and main.cpp file. They all must be in the same directory as for this example. 

You can move them as you want but make sure you rewrite the compilation commands with your specific directories.
```cpp
export module module1;

export int add(int a, int b) {
    return a + b;
}
```

```cpp
export module module2;

export int subtract(int a, int b) {
    return a - b;
}
```

```cpp
import module1;
import module2;

#include <iostream>

int main() {
    std::cout << "Add: " << add(10, 5) << std::endl;
    std::cout << "Subtract: " << subtract(10, 5) << std::endl;

    return 0;
}
```

### Make

You may compile it on your own via this list of commands

```bash
clang++ -std=c++20 -fmodules-ts --precompile module1.cppm -o module1.pcm
clang++ -std=c++20 -fmodules-ts --precompile module2.cppm -o module2.pcm
clang++ -std=c++20 -fmodules-ts -c module1.pcm -o module1.o
clang++ -std=c++20 -fmodules-ts -c module2.pcm -o module2.o
clang++ -std=c++20 -fmodules-ts -fmodule-file=module1.pcm -fmodule-file=module2.pcm -c main.cpp -o main.o
clang++ -o main main.o module1.o module2.o
```

or you can use Makefile 

```bash
make
```

The output is `main`

### CMake

If you have a large project where there is CMake or you just want to use CMake, then there are some difficulties.

First of all, you need to create a build directory

`mkdir build && cd build`

Then use a cmake 

```bash
cmake ..
make
```

Here is the CMake file
```cmake
cmake_minimum_required(VERSION 3.25)
project(modules_example)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add custom command for precompiling module1
add_custom_command(
    OUTPUT module1.pcm
    COMMAND ${CMAKE_CXX_COMPILER} -target arm64-apple-macosx13.2.0 -std=c++20 -fmodules-ts --precompile ${CMAKE_SOURCE_DIR}/module1.cppm -o module1.pcm
    DEPENDS module1.cppm
)

# Add custom command for precompiling module2
add_custom_command(
    OUTPUT module2.pcm
    COMMAND ${CMAKE_CXX_COMPILER} -target arm64-apple-macosx13.2.0 -std=c++20 -fmodules-ts --precompile ${CMAKE_SOURCE_DIR}/module2.cppm -o module2.pcm
    DEPENDS module2.cppm
)

# Add custom command for compiling module1.pcm to module1.o
add_custom_command(
    OUTPUT module1.o
    COMMAND ${CMAKE_CXX_COMPILER} -target arm64-apple-macosx13.2.0 -std=c++20 -fmodules-ts -c module1.pcm -o module1.o
    DEPENDS module1.pcm
)

# Add custom command for compiling module2.pcm to module2.o
add_custom_command(
    OUTPUT module2.o
    COMMAND ${CMAKE_CXX_COMPILER} -target arm64-apple-macosx13.2.0 -std=c++20 -fmodules-ts -c module2.pcm -o module2.o
    DEPENDS module2.pcm
)

# Add custom target for precompiling modules
add_custom_target(
    precompile_modules
    DEPENDS module1.o module2.o
)

# Add executable
add_executable(modules_example main.cpp module1.o module2.o)

# Add dependencies to precompiled modules
add_dependencies(modules_example precompile_modules)

# Add precompiled modules to compilation flags
target_compile_options(modules_example PRIVATE -fmodules-ts -fmodule-file=${CMAKE_BINARY_DIR}/module1.pcm -fmodule-file=${CMAKE_BINARY_DIR}/module2.pcm)

```

Now a quick explanation of how to work with modules in general. It is important to note that not all compilers support modules and can work with them, you should check this by yourself. I also ran into the problem that I had different target systems going through CMake - here is an example of an error: 

> Building CXX object CMakeFiles/modules_example.dir/main.cpp.o
error: PCH file was compiled for the target 'arm64-apple-macosx13.0.0' but the current translation unit is being compiled for target 'arm64-apple-macosx13.2.0'

The solution to the problem was to add target when building modules

`-target arm64-apple-macosx13.2.0`

The main algorithm for working with modules is that first we need to precompile modules and get .pcm files, then get object .o files from them.
All this should happen before linking and receiving objects .0 of cpp files.

It is also important for us to specify flags when compiling to specify the C++20 standard and the module flag

`-std=c++20 -fmodules-ts`