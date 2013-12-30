if(NOT RUSTC_FLAGS)
	set(RUSTC_FLAGS "" CACHE STRING "Flags to pass to the Rust compiler.")
endif()
mark_as_advanced(RUSTC_FLAGS)

if(NOT RUSTDOC_FLAGS)
	set(RUSTDOC_FLAGS "" CACHE STRING "Flags to pass to Rustdoc.")
endif()
mark_as_advanced(RUSTDOC_FLAGS)

function(get_rust_deps root_file out_var)
	set(dep_dir "${CMAKE_BINARY_DIR}/CMakeFiles/.cmake_rust_dependencies")
	file(MAKE_DIRECTORY "${dep_dir}")
	
	execute_process(COMMAND ${RUSTC_EXECUTABLE} ${RUSTC_FLAGS} ${ARGN} --no-analysis --dep-info "${dep_dir}/deps" "${root_file}")
	
	# Read and parse the dependency information
	file(READ "${dep_dir}/deps" crate_deps)
	file(REMOVE "${dep_dir}/deps")
	string(REGEX REPLACE ".*:(.*)" "\\1" crate_deps "${crate_deps}")
	string(STRIP "${crate_deps}" crate_deps)
	string(REPLACE " " ";" crate_deps "${crate_deps}")
	
	# Make the dependencies be relative to the source directory
	set(crate_deps_relative "")
	foreach(var IN ITEMS ${crate_deps})
		file(RELATIVE_PATH var "${CMAKE_CURRENT_SOURCE_DIR}" "${var}")
		list(APPEND crate_deps_relative "${var}")
		
		# Hack to re-run CMake if the file changes
		configure_file("${var}" "${dep_dir}/${var}" COPYONLY)
	endforeach()
	
	set(${out_var} "${crate_deps_relative}" PARENT_SCOPE)
endfunction()

macro(rust_crate target_name local_root_file target_dir dependencies)
	set(root_file "${CMAKE_SOURCE_DIR}/${local_root_file}")
	
	execute_process(COMMAND ${RUSTC_EXECUTABLE} ${RUSTC_FLAGS} ${ARGN} --crate-file-name "${root_file}"
	                OUTPUT_VARIABLE crate_filename
	                OUTPUT_STRIP_TRAILING_WHITESPACE)
	
	get_rust_deps(${root_file} crate_deps_list ${ARGN})
	
	set(comment "Building ${target_dir}/${crate_filename}")
	set(crate_filename "${CMAKE_BINARY_DIR}/${target_dir}/${crate_filename}")
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${target_dir}")
	
	add_custom_command(OUTPUT "${crate_filename}"
	                   COMMAND ${RUSTC_EXECUTABLE} ${RUSTC_FLAGS} ${ARGN} --out-dir "${CMAKE_BINARY_DIR}/${target_dir}" "${root_file}"
	                   DEPENDS ${crate_deps_list}
	                   DEPENDS ${dependencies}
	                   COMMENT "${comment}")

	add_custom_target("${target_name}"
	                  DEPENDS "${crate_filename}")
	
	set("${target_name}_ARTIFACTS" "${crate_filename}")
	# CMake Bug #10082
	set("${target_name}_DEPS" "${target_name};${crate_filename}")
endmacro(rust_crate) 

macro(rust_doc target_name local_root_file target_dir dependencies)
	set(root_file "${CMAKE_SOURCE_DIR}/${local_root_file}")
	
	execute_process(COMMAND ${RUSTC_EXECUTABLE} ${RUSTC_FLAGS} ${ARGN} --crate-name "${root_file}"
	                OUTPUT_VARIABLE crate_name
	                OUTPUT_STRIP_TRAILING_WHITESPACE)

	get_rust_deps(${root_file} crate_deps_list ${ARGN})
	
	set(doc_dir "${CMAKE_BINARY_DIR}/${target_dir}/${crate_name}")
	set(src_dir "${CMAKE_BINARY_DIR}/${target_dir}/src/${crate_name}")
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${target_dir}")
	
	add_custom_command(OUTPUT "${doc_dir}" "${src_dir}"
	                   COMMAND ${RUSTDOC_EXECUTABLE} ${RUSTDOC_FLAGS} ${ARGN} -o "${CMAKE_BINARY_DIR}/${target_dir}" "${root_file}"
	                   # Otherwise CMake will never stop remaking the documentation after a change that doesn't change the output
	                   COMMAND ${CMAKE_COMMAND} -E touch "${doc_dir}"
	                   COMMAND ${CMAKE_COMMAND} -E touch "${src_dir}"
	                   DEPENDS ${crate_deps_list}
	                   DEPENDS ${dependencies})

	add_custom_target("${target_name}"
	                  DEPENDS "${doc_dir}"
	                  DEPENDS "${src_dir}")
	
	set("${target_name}_ARTIFACTS" "${doc_dir};${src_dir}")
	# CMake Bug #10082
	set("${target_name}_DEPS" "${target_name};${doc_dir};${src_dir}")
endmacro(rust_doc)
