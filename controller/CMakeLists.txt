add_executable(
    premature-load-controller
    src/main.cpp
)

target_include_directories(
    premature-load-controller
    PRIVATE include
)
