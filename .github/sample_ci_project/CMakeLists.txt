cmake_minimum_required(VERSION 3.5)

project(microros_sample_project)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..)

# Get source files
file(GLOB_RECURSE EXAMPLE_SOURCES
    ${ROOT_DIR}/examples/*.c
)

file(GLOB_RECURSE SUPPORT_SOURCES
    ${ROOT_DIR}/microros_vitis_support/*.c
)

# Generate executable
add_executable(${PROJECT_NAME}
    ${EXAMPLE_SOURCES}
    ${SUPPORT_SOURCES}
    linking_mocks.c
)

# Add include directories
target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${ROOT_DIR}/microros_vitis_support
    ${ROOT_DIR}/examples
    ${CMAKE_CURRENT_SOURCE_DIR}/lwip_fake_port
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/lwip/contrib/ports/freertos/include
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/lwip/src/include
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/freertos/include
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/freertos/portable/GCC/ARM_CR5
)

# Add micro-ROS library
target_link_directories(${PROJECT_NAME}
    PRIVATE
    ${ROOT_DIR}/microros_generic_arm_lib
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    microros
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${ROOT_DIR}/microros_generic_arm_lib/include
)