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
