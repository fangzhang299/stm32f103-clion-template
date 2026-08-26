cmake_minimum_required(VERSION 3.22)

#
# STM32F103C8Tx (Medium Density) + STM32F10x Standard Peripheral Library (SPL)
#
# Directory layout:
#   User/       main.c, stm32f10x_it.c, stm32f10x_conf.h
#   Start/      startup_stm32f10x_md.s, core_cm3.c, system_stm32f10x.c, CMSIS headers
#   Library/    STM32F10x Standard Peripheral Library (inc/ + src/)
#   Hardware/   Board peripherals (Key, LED, OLED)
#   System/     System utilities (Delay)
#
# Toolchain/linker flags come from cmake/gcc-arm-none-eabi.cmake (via CMakePresets.json)
#

# Setup compiler settings
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

# Define the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Set the project name
set(CMAKE_PROJECT_NAME Clion_STL_model)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${CMAKE_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# --- Sources -----------------------------------------------------------------

# Startup & core
set(STARTUP_SRC
    Start/startup_stm32f10x_md.s
    Start/core_cm3.c
    Start/system_stm32f10x.c
)

# User application
set(USER_SRC
    User/main.c
    User/stm32f10x_it.c
)

# System utilities
set(SYSTEM_SRC
    System/Delay.c
)

# Board peripherals
set(HARDWARE_SRC
    Hardware/Key.c
    Hardware/LED.c
    Hardware/OLED.c
)

# Standard Peripheral Library drivers
file(GLOB_RECURSE LIB_SRC CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/Library/src/*.c
)

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME}
    ${STARTUP_SRC}
    ${USER_SRC}
    ${SYSTEM_SRC}
    ${HARDWARE_SRC}
    ${LIB_SRC}
)

# --- Include paths -----------------------------------------------------------
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Start
    ${CMAKE_CURRENT_SOURCE_DIR}/Library/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/User
    ${CMAKE_CURRENT_SOURCE_DIR}/Hardware
    ${CMAKE_CURRENT_SOURCE_DIR}/System
)

# --- Compile definitions (macros) --------------------------------------------
# STM32F10X_MD            : Medium density (STM32F103C8)
# USE_STDPERIPH_DRIVER    : enable stm32f10x_conf.h inclusion in stm32f10x.h
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    STM32F10X_MD
    USE_STDPERIPH_DRIVER
    $<$<CONFIG:Debug>:DEBUG>
)

# --- Link libraries ----------------------------------------------------------
# TOOLCHAIN_LINK_LIBRARIES is defined by cmake/gcc-arm-none-eabi.cmake (= m)
target_link_libraries(${CMAKE_PROJECT_NAME}
    ${TOOLCHAIN_LINK_LIBRARIES}
)

# Add the map file to the list of files to be removed with 'clean' target
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_PROJECT_NAME}.map)
