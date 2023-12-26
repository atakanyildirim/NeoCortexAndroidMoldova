cmake_minimum_required(VERSION 3.6.0)
set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -stdlib=libc++")
SET(CMAKE_EXE_LINKER_FLAGS  "-lopencv_stitching -lopencv_core")
SET(BUILD_SHARED_LIBS ON)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
file(GLOB CVLIBS
        "/Users/atakanyildirim/Downloads/OpenCV-android-sdk/sdk/native/staticlibs/${ANDROID_ABI}/libopencv_stitching.a")
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)
set(SOURCES
    ../../lib/opencv-cpp/main.cpp
)
add_library(OpenCV_ffi SHARED ${SOURCES})
target_link_libraries(OpenCV_ffi ${CVLIBS} lib_opencv)