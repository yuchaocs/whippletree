set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})

option(CUDA_BUILD_CC30 "Build with compute capability 3.0 support" FALSE)
option(CUDA_BUILD_CC35 "Build with compute capability 3.5 support" FALSE)
option(CUDA_BUILD_CC35_NODYN "Build with compute capability 3.5 support without dynamic parallelism" TRUE)
option(CUDA_BUILD_CC50 "Build with compute capability 5.0 support" FALSE)
option(CUDA_BUILD_CC50_NODYN "Build with compute capability 5.0 support without dynamic parallelism" FALSE)
option(CUDA_BUILD_INFO "Build with kernel statistics and line numbers" TRUE)
option(CUDA_BUILD_DEBUG "Build with kernel debug" FALSE)
option(CUDA_ENABLE_CUPTI_INSTRUMENTATION "enable CUPTI instrumentation" TRUE)

find_package(CUDA REQUIRED)

set(CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE OFF CACHE BOOL "ATTACH")
if(WIN32)
        set(CUDA_PROPAGATE_HOST_FLAGS ON CACHE BOOL "ATTACH")
else()
        set(CUDA_PROPAGATE_HOST_FLAGS OFF)
endif()
set(CUDA_NVCC_FLAGS "-use_fast_math")

# On Linux the code requires CUDA compiler with C++11 support (CUDA 6.5RC or later).
set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-std=c++11;")

set(CUDA_MAXRREGCOUNT "-maxrregcount=63;")

# CC 2.0 is always required for printf
#set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-gencode=arch=compute_20,code=sm_20;")

if(CUDA_BUILD_CC30)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-gencode=arch=compute_30,code=sm_30;")
endif()
if(CUDA_BUILD_CC35 OR CUDA_BUILD_CC35_NODYN)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-gencode=arch=compute_35,code=sm_35;${CUDA_MAXRREGCOUNT}")
	set(CUDA_MAXRREGCOUNT "")
endif()
if(CUDA_BUILD_CC50)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-gencode=arch=compute_50,code=sm_50;")
endif()
if(CUDA_BUILD_CC50 OR CUDA_BUILD_CC50_NODYN)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-gencode=arch=compute_50,code=sm_50;${CUDA_MAXRREGCOUNT}")
	set(CUDA_MAXRREGCOUNT "")
endif()
if(CUDA_BUILD_INFO)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-keep;--ptxas-options=-v;-lineinfo")
endif()
if(CUDA_BUILD_DEBUG)
	set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-G")
endif()

set(CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE OFF CACHE BOOL "ATTACH")
if(WIN32)
	set(CUDA_PROPAGATE_HOST_FLAGS ON CACHE BOOL "ATTACH")
else()
	set(CUDA_PROPAGATE_HOST_FLAGS OFF CACHE BOOL "ATTACH")
endif()

if (NOT WIN32)
	set(CMAKE_CXX_FLAGS "-std=c++11") 
endif ()

# We have GPU global variables defined in multiple .cu files
set(CUDA_SEPARABLE_COMPILATION ON)

# Enable/disable debugging
#set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS};-g;-G;-O0;")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")

include_directories(${CUDA_INCLUDE_DIRS})

add_definitions(-D_CUDA)
add_definitions(-D_DEVICE)
add_definitions(-DthreadIdx_x=threadIdx.x)
add_definitions(-DblockDim_x=blockDim.x)
add_definitions(-DblockIdx_x=blockIdx.x)
add_definitions(-DgridDim_x=gridDim.x)

