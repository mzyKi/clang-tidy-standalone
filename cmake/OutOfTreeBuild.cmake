if(NOT ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
  message(FATAL "Only include this module when building out of LLVM tree")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)

set(CLANG_TIDY_OUT_OF_TREE_BUILD true)
set(CLANG_BUILD_TOOLS ON CACHE BOOL
  "For target clang-tidy, prevent from being EXCLUDE_FROM_ALL" FORCE)

find_package(Clang REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Found LLVMConfig.cmake in ${LLVM_DIR}")

list(APPEND CMAKE_MODULE_PATH ${LLVM_DIR})
list(APPEND CMAKE_MODULE_PATH ${Clang_DIR})
include(AddLLVM)
include(AddClang)
include(BuildWithCCache)

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${CLANG_INCLUDE_DIRS})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall -pedantic -fPIC -fvisibility-inlines-hidden -fno-rtti")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -ffunction-sections -fdata-sections -fno-common -fno-strict-aliasing")

if(TARGET clangStaticAnalyzerCheckers)
  set(CLANG_TIDY_ENABLE_STATIC_ANALYZER ON CACHE BOOL
    "Build static analyzer.")
endif()

set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
add_custom_target(ClangSACheckers) # faked for clangTidy

# In case assertion is needed
# see llvm/cmake/modules/HandleLLVMOptions.cmake
if( LLVM_ENABLE_ASSERTIONS )
  # MSVC doesn't like _DEBUG on release builds. See PR 4379.
  if( NOT MSVC )
    add_definitions( -D_DEBUG )
  endif()
  # On non-Debug builds cmake automatically defines NDEBUG, so we
  # explicitly undefine it:
  if( NOT uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG" )
    add_definitions( -UNDEBUG )
    # Also remove /D NDEBUG to avoid MSVC warnings about conflicting defines.
    foreach (flags_var_to_scrub
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS_MINSIZEREL
        CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS_MINSIZEREL)
      string (REGEX REPLACE "(^| )[/-]D *NDEBUG($| )" " "
        "${flags_var_to_scrub}" "${${flags_var_to_scrub}}")
    endforeach()
  endif()
endif()
