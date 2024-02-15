<!-- ![banner](.images/banner-dark-theme.png#gh-dark-mode-only)
![banner](.images/banner-light-theme.png#gh-light-mode-only) -->

# micro-ROS for AMD Vitis

This package eases the integration of [micro-ROS](https://micro.ros.org/) in a [AMD Vitis](https://www.xilinx.com/products/design-tools/vitis.html). This components targets building the micro-ROS library for different targets or architectures supported by AMD Vitis.

- [micro-ROS for AMD Vitis](#micro-ros-for-amd-vitis)
  - [Supported targets](#supported-targets)
  - [Prerequisites](#prerequisites)
  - [Building the micro-ROS library](#building-the-micro-ros-library)
  - [Configuring micro-ROS library memory](#configuring-micro-ros-library-memory)
  - [Adding custom packages to the micro-ROS build](#adding-custom-packages-to-the-micro-ros-build)

## Supported targets

| Target     | `MICROROS_TARGET`  |
| ---------- | ------------------ |
| MicroBlaze | `VITIS_MICROBLAZE` |
| Cortex R5  | `VITIS_CORTEX_R5`  |

## Prerequisites

- [AMD Vitis](https://www.xilinx.com/products/design-tools/vitis.html) installed.
- Valid compiler for the target architecture installed and available in the `PATH`.
- The following Python packages installed:

```bash
pip3 install colcon-common-extensions catkin_pkg lark-parser empy
```

- The following packages installed in the system:

```bash
sudo apt install rsync
```

## Building the micro-ROS library

In order to generate the micro-ROS library for a specific target, the following command must be executed:

```bash
MICROROS_TARGET=<target> ./build_micro_ros_library.sh
```

Where `<target>` is the target architecture to build the micro-ROS library for, as specified in the [Supported targets](#supported-targets) section.

## Configuring micro-ROS library memory

As explained in the [micro-ROS documentation](https://docs.vulcanexus.org/en/latest/rst/tutorials/micro/memory_management/memory_management.html) some of the micro-ROS memory is statically allocated at compile time.
This means that the memory configuration must be adjusted to the specific target architecture.

In order to tune the memory configuration, `colcon.meta` file must be edited according to the fit application requirements.

## Adding custom packages to the micro-ROS build

In order to include a custom package in the micro-ROS build, just copy the package folder into `library_generation/extra_packages` folder. The build system will automatically detect the package and build it along with the micro-ROS library.

Note that a library rebuild is needed to include the package, this can be achieved by deleting the `libmicroros` generated folder and building your project afterwards.
