#!/bin/bash

# Depending on the MICROROS_TARGET environment variable, this script will build the micro-ROS library for the selected target.
# The following targets are supported:
# - VITIS_MICROBLAZE
# - VITIS_CORTEX_R5
# - GENERIC_ARM

# Set compiler flags
export MICROROS_FLAGS=""

# MicroBlaze custom flags
export MICROBLAZE_ENDIANNESS_FLAG="-mlittle-endian"
export MICROBLAZE_64BITS=""

# Iterate over the arguments
for arg in "$@"
do
    case $arg in
        -f)
        export FORCE_BUILD=1
        shift
        ;;
        -v)
        export VERBOSE_BUILD=1
        shift
        ;;
        -bigendiann)
        export MICROBLAZE_ENDIANNESS_FLAG="-mbig-endian"
        shift
        ;;
        -64bits)
        export MICROBLAZE_64BITS="-m64"
        shift
        ;;
        *)
        # Unknown option
        echo "Unknown option: $arg"
        exit 1
        ;;
    esac
done

# Check if ROS 2 is sourced
if command -v "ros2" >/dev/null 2>&1
then
    echo "ROS 2 sourced, please run this script in a new terminal without sourcing ROS 2"
    exit
fi

# Check if MICROROS_TARGET is set
if [ -z "${MICROROS_TARGET}" ]; then
    echo "MICROROS_TARGET is not set"
    exit
fi

# Check if MICROROS_TARGET is supported
if  [ "${MICROROS_TARGET}" != "VITIS_MICROBLAZE" ] &&
    [ "${MICROROS_TARGET}" != "VITIS_CORTEX_R5" ] &&
    [ "${MICROROS_TARGET}" != "GENERIC_ARM" ]; then
    echo "MICROROS_TARGET ${MICROROS_TARGET} is not supported"
    exit
fi

# Set toolchain prefixes
if [ "${MICROROS_TARGET}" = "VITIS_MICROBLAZE" ]; then
    export TOOLCHAIN_PREFIX=mb-
    export MICROROS_FLAGS="${MICROROS_FLAGS} ${MICROBLAZE_ENDIANNESS_FLAG} ${MICROBLAZE_64BITS} -fPIC"
elif [ "${MICROROS_TARGET}" = "VITIS_CORTEX_R5" ]; then
    export TOOLCHAIN_PREFIX=armr5-none-eabi-
elif [ "${MICROROS_TARGET}" = "GENERIC_ARM" ]; then
    export TOOLCHAIN_PREFIX="arm-none-eabi-"
fi

# Define compilers
export C_COMPILER=${TOOLCHAIN_PREFIX}gcc
export CXX_COMPILER=${TOOLCHAIN_PREFIX}g++

# Check if compilers are available
if ! command -v "${C_COMPILER}" >/dev/null 2>&1
then
    echo "${C_COMPILER} command could not be found"
    echo "Please add required toolchain to the PATH"
    exit 1
fi

if ! command -v "${CXX_COMPILER}" >/dev/null 2>&1
then
    echo "${CXX_COMPILER} command could not be found"
    echo "Please add required toolchain to the PATH"
    exit 1
fi

# Define micro-ROS environment variables
export MICRO_ROS_DISTRO=iron

# Set toolchain prefixes
if [ "${MICROROS_TARGET}" = "VITIS_MICROBLAZE" ]; then
    export MICRO_ROS_BUILD_DIR=microros_build_microblaze
elif [ "${MICROROS_TARGET}" = "VITIS_CORTEX_R5" ]; then
    export MICRO_ROS_BUILD_DIR=microros_build_cortex_r5
elif [ "${MICROROS_TARGET}" = "GENERIC_ARM" ]; then
    export MICRO_ROS_BUILD_DIR=microros_build_generic_arm
fi

mkdir -p $MICRO_ROS_BUILD_DIR

# If FORCE_BUILD clean $MICRO_ROS_BUILD_DIR directory
if [ -n "${FORCE_BUILD}" ]; then
    rm -rf $MICRO_ROS_BUILD_DIR/*
fi

# If $MICRO_ROS_BUILD_DIR/dev/src exists, skip this
if [ ! -d "$MICRO_ROS_BUILD_DIR/dev/src" ]; then
    # Generate micro-ROS dev environment
    mkdir -p $MICRO_ROS_BUILD_DIR/dev/
    pushd $MICRO_ROS_BUILD_DIR/dev/ > /dev/null
        # Dev environment
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ament/ament_cmake src/ament_cmake;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ament/ament_lint src/ament_lint;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ament/ament_package src/ament_package;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ament/googletest src/googletest;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/ament_cmake_ros src/ament_cmake_ros;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ament/ament_index src/ament_index;
    popd > /dev/null
fi

# Define colcon event handlers depending of VERBOSE_BUILD
if [ -n "${VERBOSE_BUILD}" ]; then
    export COLCON_EVENT_HANDLERS="";
else
    export COLCON_EVENT_HANDLERS="--event-handlers compile_commands- console_stderr-";
fi

# If $MICRO_ROS_BUILD_DIR/dev/install exists, skip this
if [ ! -d "$MICRO_ROS_BUILD_DIR/dev/install" ]; then
    # Install micro-ROS dev environment
    pushd $MICRO_ROS_BUILD_DIR/dev/ > /dev/null
        colcon build $COLCON_EVENT_HANDLERS;
    popd > /dev/null
fi

# Extra packages folder
export MICROROS_EXTRA_PACKAGES=$(pwd)/extra_packages

# Toolchain file
export TOOLCHAIN=$(pwd)/toolchain.cmake

# If $MICRO_ROS_BUILD_DIR/microros exists, skip this
if [ ! -d "$MICRO_ROS_BUILD_DIR/microros/src" ]; then
    # Generate micro-ROS firmware environment
    mkdir -p $MICRO_ROS_BUILD_DIR/microros/
    pushd $MICRO_ROS_BUILD_DIR/microros/ > /dev/null
        # Firmware environment
        git clone -b ros2 https://github.com/eProsima/Micro-XRCE-DDS-Client src/Micro-XRCE-DDS-Client;
        git clone -b ros2 https://github.com/eProsima/micro-CDR src/micro-CDR;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/rmw_microxrcedds src/rmw_microxrcedds;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/rcl src/rcl;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rclc src/rclc;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/rcutils src/rcutils;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/micro_ros_msgs src/micro_ros_msgs;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/rosidl_typesupport src/rosidl_typesupport;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/rosidl_typesupport_microxrcedds src/rosidl_typesupport_microxrcedds;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rosidl src/rosidl;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rosidl_dynamic_typesupport src/rosidl_dynamic_typesupport;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rmw src/rmw;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rcl_interfaces src/rcl_interfaces;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rosidl_defaults src/rosidl_defaults;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/unique_identifier_msgs src/unique_identifier_msgs;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/common_interfaces src/common_interfaces;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/example_interfaces src/example_interfaces;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/test_interface_files src/test_interface_files;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rmw_implementation src/rmw_implementation;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rcl_logging src/rcl_logging;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/ros2_tracing src/ros2_tracing;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/micro-ROS/micro_ros_utilities src/micro_ros_utilities;
        git clone -b ${MICRO_ROS_DISTRO} https://github.com/ros2/rosidl_core src/rosidl_core;
        touch src/rosidl/rosidl_typesupport_introspection_cpp/COLCON_IGNORE;
        touch src/rcl_logging/rcl_logging_spdlog/COLCON_IGNORE;
        touch src/rclc/rclc_examples/COLCON_IGNORE;
        touch src/rcl/rcl_yaml_param_parser/COLCON_IGNORE;
        touch src/ros2_tracing/test_tracetools/COLCON_IGNORE;

        # Add extra packages
        cp -rf $MICROROS_EXTRA_PACKAGES src/extra_packages || :;
        test -f src/extra_packages/extra_packages.repos && cd src/extra_packages && vcs import --input extra_packages.repos || :;
    popd > /dev/null
fi

# Source micro-ROS dev environment
source $MICRO_ROS_BUILD_DIR/dev/install/local_setup.sh;

# Set colcon meta
export COLCON_META=$(pwd)/colcon.meta

# If $MICRO_ROS_BUILD_DIR/microros/install exists, skip this
if [ ! -d "$MICRO_ROS_BUILD_DIR/microros/install" ]; then
    # Install micro-ROS firmware environment
    pushd $MICRO_ROS_BUILD_DIR/microros/ > /dev/null
        # Build
        colcon build \
            --merge-install \
            --packages-ignore-regex=.*_cpp \
            --metas $COLCON_META \
            $COLCON_EVENT_HANDLERS \
            --cmake-args \
            "--no-warn-unused-cli" \
            -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=OFF \
            -DTHIRDPARTY=ON \
            -DBUILD_SHARED_LIBS=OFF \
            -DBUILD_TESTING=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
            -DCMAKE_VERBOSE_MAKEFILE=ON;

        # Fix include paths
        echo "Fixing include paths for micro-ROS packages"
        INCLUDE_ROS2_PACKAGES=$(colcon list | awk '{print $1}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}')

        for var in ${INCLUDE_ROS2_PACKAGES}; do
            rsync -r ./install/include/${var}/${var}/* ./install/include/${var}/ > /dev/null 2>&1
            rm -rf ./install/include/${var}/${var}/ > /dev/null 2>&1
        done

        # # Delete all empty folder in install/include
        find ./install/include -type d -empty -delete

    popd > /dev/null
fi

# Generate the output folder
if [ "${MICROROS_TARGET}" = "VITIS_MICROBLAZE" ]; then
    export OUTPUT_FOLDER=microros_microblaze_lib
elif [ "${MICROROS_TARGET}" = "VITIS_CORTEX_R5" ]; then
    export OUTPUT_FOLDER=microros_cortex_r5_lib
elif [ "${MICROROS_TARGET}" = "GENERIC_ARM" ]; then
    export OUTPUT_FOLDER=microros_generic_arm_lib
fi

rm -rf ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER}

# Copy includes
mkdir -p ${OUTPUT_FOLDER}/include
cp -r $MICRO_ROS_BUILD_DIR/microros/install/include/* ${OUTPUT_FOLDER}/include

# Generate combined libraries
echo "Creating libmicroros.a"
pushd $MICRO_ROS_BUILD_DIR/microros > /dev/null
    echo "CREATE libmicroros.a" > ar_script
    find install/lib -name "*.a" -exec echo "ADDLIB $(pwd)/{}" >> ar_script \;
    echo "SAVE" >> ar_script
popd > /dev/null
pushd ${OUTPUT_FOLDER} > /dev/null
    ar -M < ../$MICRO_ROS_BUILD_DIR/microros/ar_script
popd > /dev/null

