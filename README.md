#### clang-tidy-standalone(based on llvm-org-18.1.8)

decouple clang-tidy from llvm-project

#### Build
```bash
$ mkdir build && cd build
$ cmake -DClang_DIR=${YOUR_NATIVE_CLANG} -DLLVM_DIR=${YOUR_NATIVE_LLVM} ..
$ make -j12
$ bin/clang-tidy ...
```

#### Tips
\${YOUR_NATIVE_CLANG} \${YOUR_NATIVE_LLVM} means your build llvm-project and install
for example, you build llvm-project(llvm-org-18.1.8) like the following:
```bash
$ cd llvm-project
$ mkdir build && cd build
$ cmake -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DLLVM_TARGETS_TO_BUILD=X86 -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Debug ../llvm
$ make -j12 install
```

\${YOUR_NATIVE_CLANG} = \${INSTALL_DIR}/lib/cmake/clang  
\${YOUR_NATIVE_LLVM} = \${INSTALL_DIR}/lib/cmake/llvm
