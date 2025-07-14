set(LLVM_LINK_COMPONENTS
  AllTargetsAsmParsers
  AllTargetsDescs
  AllTargetsInfos
  FrontendOpenMP
  support
  )

if(CLANG_TIDY_OUT_OF_TREE_BUILD)
  add_custom_target(clang-resource-headers) # fake target for add_clang_tool
  add_custom_target(build-clang-tidy ALL) # link clang-tidy to all
  add_dependencies(build-clang-tidy clang-tidy)
endif(CLANG_TIDY_OUT_OF_TREE_BUILD)

# Needed by LLVM's CMake checks because this file defines multiple targets.
set(LLVM_OPTIONAL_SOURCES ClangTidyMain.cpp ClangTidyToolMain.cpp)

add_clang_library(clangTidyMain
  ClangTidyMain.cpp

  LINK_LIBS
  clangTidy
  ${ALL_CLANG_TIDY_CHECKS}

  DEPENDS
  omp_gen
  )

clang_target_link_libraries(clangTidyMain
  PRIVATE
  clangAST
  clangASTMatchers
  clangBasic
  clangTooling
  clangToolingCore
  )

# Support plugins.
if(CLANG_PLUGIN_SUPPORT)
  set(support_plugins SUPPORT_PLUGINS)
endif()

add_clang_tool(clang-tidy
  ClangTidyToolMain.cpp

  DEPENDS
  clang-resource-headers
  ${support_plugins}
  )
clang_target_link_libraries(clang-tidy
  PRIVATE
  clangAST
  clangASTMatchers
  clangBasic
  clangTooling
  clangToolingCore
  )
target_link_libraries(clang-tidy
  PRIVATE
  clangTidy
  clangTidyMain
  ${ALL_CLANG_TIDY_CHECKS}
  )

if(CLANG_PLUGIN_SUPPORT)
  export_executable_symbols_for_plugins(clang-tidy)
endif()

install(PROGRAMS clang-tidy-diff.py
  DESTINATION "${CMAKE_INSTALL_DATADIR}/clang"
  COMPONENT clang-tidy)
install(PROGRAMS run-clang-tidy.py
  DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT clang-tidy
  RENAME run-clang-tidy)

