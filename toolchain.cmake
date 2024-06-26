SET(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER $ENV{TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER $ENV{TOOLCHAIN_PREFIX}g++)

SET(CMAKE_C_COMPILER_WORKS 1 CACHE INTERNAL "")
SET(CMAKE_CXX_COMPILER_WORKS 1 CACHE INTERNAL "")

message("micro-ROS lib using flags: $ENV{MICROROS_FLAGS}")
set(CMAKE_C_FLAGS_INIT "-std=c11 $ENV{MICROROS_FLAGS} " CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_INIT "-std=c++14 -fno-rtti $ENV{MICROROS_FLAGS} " CACHE STRING "" FORCE)

add_compile_definitions(CLOCK_MONOTONIC=0)