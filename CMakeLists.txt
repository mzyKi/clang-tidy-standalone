project(clang-tidy-standalone C CXX) 
cmake_minimum_required(VERSION 3.25)

set(LLVM_LINK_COMPONENTS
  FrontendOpenMP
  Support
  )

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
  include(OutOfTreeBuild)
endif()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/clang-tidy-config.h.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/clang-tidy-config.h)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
include(utils)

in_source_build_guard()
set_default_build_type(Debug)

find_package(LLVM REQUIRED CONFIG)
find_package(Clang REQUIRED CONFIG)

include_directories(/home/mzy/Github/llvm-project/build_native/include)
link_directories(/home/mzy/Github/llvm-project/build_native/lib)


add_clang_library(clangTidy
  ClangTidy.cpp
  ClangTidyCheck.cpp
  ClangTidyModule.cpp
  ClangTidyDiagnosticConsumer.cpp
  ClangTidyOptions.cpp
  ClangTidyProfiling.cpp
  ExpandModularHeadersPPCallbacks.cpp
  GlobList.cpp
  NoLintDirectiveHandler.cpp

  DEPENDS
  ClangSACheckers
  omp_gen
  )

clang_target_link_libraries(clangTidy
  PRIVATE
  clangAnalysis
  clangAST
  clangASTMatchers
  clangBasic
  clangFormat
  clangFrontend
  clangLex
  clangRewrite
  clangSerialization
  clangTooling
  clangToolingCore
)

if(CLANG_TIDY_ENABLE_STATIC_ANALYZER)
  clang_target_link_libraries(clangTidy
    PRIVATE
    clangStaticAnalyzerCore
    clangStaticAnalyzerFrontend
  )
endif()

# Checks.
# If you add a check, also add it to ClangTidyForceLinker.h in this directory.
add_subdirectory(misc)
set(ALL_CLANG_TIDY_CHECKS
  clangTidyMiscModule
  )

# Other subtargets. These may reference ALL_CLANG_TIDY_CHECKS
# and must be below its definition.
add_subdirectory(tool)
add_subdirectory(utils)

