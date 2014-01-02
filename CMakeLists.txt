cmake_minimum_required(VERSION 2.8)
project(test NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
find_package(rustc)
find_package(rustdoc)
include(Rust)

set(RUSTC_FLAGS "-L${CMAKE_BINARY_DIR}/lib")
set(RUSTDOC_FLAGS "-L${CMAKE_BINARY_DIR}/lib")

# Get the dependencies of all the crates
get_rust_deps(src/lib.rs TEST_DEPS)
get_rust_deps(examples/example1.rs EXAMPLE1_DEPS)
get_rust_deps(examples/example2.rs EXAMPLE2_DEPS)

# Build the library
rust_crate(src/lib.rs
           TARGET_NAME TEST
           DESTINATION lib
           DEPENDS "${TEST_DEPS}")

add_custom_target(library_target
                  ALL
                  DEPENDS ${TEST_FULL_TARGET})

# Build examples
rust_crate(examples/example1.rs
           TARGET_NAME EXAMPLE1
           DESTINATION examples
           DEPENDS "${TEST_FULL_TARGET};${EXAMPLE1_DEPS}")
rust_crate(examples/example2.rs
           TARGET_NAME EXAMPLE2
           DESTINATION examples
           DEPENDS "${TEST_FULL_TARGET};${EXAMPLE2_DEPS}")

add_custom_target(examples_target
                  ALL
                  DEPENDS ${EXAMPLE1_FULL_TARGET} ${EXAMPLE2_FULL_TARGET})

# Build tests
rust_crate(examples/example1.rs
           TARGET_NAME EXAMPLE1_TEST
           DESTINATION test
           DEPENDS "${TEST_FULL_TARGET};${EXAMPLE1_DEPS}"
           OTHER_RUSTC_FLAGS --test)
rust_crate(examples/example2.rs
           TARGET_NAME EXAMPLE2_TEST
           DESTINATION test
           DEPENDS "${TEST_FULL_TARGET};${EXAMPLE2_DEPS}"
           OTHER_RUSTC_FLAGS --test)

add_custom_target(test
                  COMMAND ./example1 || true
                  COMMAND ./example2 || true
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/test"
                  DEPENDS ${EXAMPLE1_TEST_FULL_TARGET} ${EXAMPLE2_TEST_FULL_TARGET})


# Build documentation
rust_doc(src/lib.rs
         TARGET_NAME TEST_DOC
         DESTINATION doc
         DEPENDS "${TEST_DEPS}")
rust_doc(examples/example1.rs
         TARGET_NAME EXAMPLE1_DOC
         DESTINATION doc
         DEPENDS "${TEST_FULL_TARGET};${EXAMPLE1_DEPS}")
rust_doc(examples/example2.rs
         TARGET_NAME EXAMPLE2_DOC
         DESTINATION doc
         DEPENDS "${TEST_FULL_TARGET};${EXAMPLE2_DEPS}")

add_custom_target(doc
                  DEPENDS ${TEST_DOC_FULL_TARGET} ${EXAMPLE1_DOC_FULL_TARGET} ${EXAMPLE2_DOC_FULL_TARGET})

# Install library
install(FILES ${TEST_ARTIFACTS}
        DESTINATION lib)
