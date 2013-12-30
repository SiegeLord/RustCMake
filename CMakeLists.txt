cmake_minimum_required(VERSION 2.8)
project(test NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
find_package(rustc)
find_package(rustdoc)
include(Rust)

set(RUSTC_FLAGS "-L${CMAKE_BINARY_DIR}/lib")
set(RUSTDOC_FLAGS "-L${CMAKE_BINARY_DIR}/lib")

# Build the library
rust_crate(TEST src/lib.rs lib "")

add_custom_target(library_target
                  ALL
                  DEPENDS ${TEST_DEPS})

# Build examples
rust_crate(EXAMPLE1 examples/example1.rs examples "${TEST_DEPS}")
rust_crate(EXAMPLE2 examples/example2.rs examples "${TEST_DEPS}")

add_custom_target(examples_target
                  ALL
                  DEPENDS ${EXAMPLE1_DEPS} ${EXAMPLE2_DEPS})

# Build tests
rust_crate(EXAMPLE1_TEST examples/example1.rs test "${TEST_DEPS}" --test)
rust_crate(EXAMPLE2_TEST examples/example2.rs test "${TEST_DEPS}" --test)

add_custom_target(test
                  COMMAND ./example1 || true
                  COMMAND ./example2 || true
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/test"
                  DEPENDS ${EXAMPLE1_TEST_DEPS} ${EXAMPLE2_TEST_DEPS})


# Build documentation
rust_doc(TEST_DOC src/lib.rs doc "")
rust_doc(EXAMPLE1_DOC examples/example1.rs doc "${TEST_DEPS}")
rust_doc(EXAMPLE2_DOC examples/example2.rs doc "${TEST_DEPS}")

add_custom_target(doc
                  DEPENDS ${TEST_DOC_DEPS} ${EXAMPLE1_DOC_DEPS} ${EXAMPLE2_DOC_DEPS})

# Install library
install(FILES ${TEST_ARTIFACTS}
        DESTINATION lib)
