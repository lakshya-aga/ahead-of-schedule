cmake_minimum_required(VERSION 3.20)

project(
    premature_load
    VERSION 0.1.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(controller)
add_subdirectory(benchmarks)
