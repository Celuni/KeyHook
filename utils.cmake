# Definitions for different platforms

# Normalize definitions
if (CYGWIN)
    set(UNIX FALSE)
    set(WIN32 TRUE)
endif ()
if (UNIX AND NOT APPLE)
    set(LINUX TRUE)
    message("UNIX AND NOT APPLE")
endif ()

# Add definitions
if (WIN32)
    add_definitions(-D_WIN32_)
elseif (APPLE)
    add_definitions(-D_APPLE_)
elseif (LINUX)
    add_definitions(-D_LINUX_)
endif ()

# Find architecture bitness
if (CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(BITNESS x86)
elseif (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BITNESS x64)
elseif ()
    message("Unkown architecture bitness")
endif ()

# Appends "files" to "variable"
function(append variable files)
    set(${variable} ${${variable}} ${files} PARENT_SCOPE)
endfunction(append)

# Appends "str" to "variable"
function(append_str variable str)
    set(${variable} "${${variable}}${str}" PARENT_SCOPE)
endfunction(append_str)

# Sets some flags that are generally useful to have
function(append_default_cxx_flags return)
    set(flags "")
    # Link gcc dependencies statically to binaries on windows
    if (WIN32)
        append_str(flags " -static-libgcc -static-libstdc++")
    endif ()
    # Use ptreads if not on windows
    if (NOT WIN32)
        append_str(flags " -pthread")
    endif ()
    # Gcc perfomance report
    #    append_str(flags " -ftime-report")
    # Return
    set(${return} "${${return}} ${flags}" PARENT_SCOPE)
endfunction(append_default_cxx_flags)

# Converts a list to a string with custom delimiter
function(list_to_str result delim)
    list(GET ARGV 2 temp)
    math(EXPR N "${ARGC}-1")
    foreach (IDX RANGE 3 ${N})
        list(GET ARGV ${IDX} STR)
        set(temp "${temp}${delim}${STR}")
    endforeach ()
    set(${result} "${temp}" PARENT_SCOPE)
endfunction(list_to_str)

# Updates a file if content has changed
function(update_file path content)
    set(old_content "")
    if (EXISTS "${path}")
        file(READ "${path}" old_content)
    endif ()
    if (NOT old_content STREQUAL content)
        file(WRITE "${path}" "${content}")
    endif ()
endfunction(update_file)

# Retriggers cmake if "sources" has changed
# This is done by creating a cache of all files that are tracked by cmake
function(watch_source_change sources cache_name)
    list(REMOVE_DUPLICATES sources)
    list(SORT sources)
    list_to_str(str "\n" ${sources})
    set(content "# List of all source files\n# Generated by CMake\nset(sources\n${str}\n)\n")
    update_file(${cache_name} "${content}")
    # Include the file so it's tracked when changed (we don't need the content).
    include(${cache_name})
endfunction(watch_source_change)

# Find all files given by path
function(find_sources return path)
    file(GLOB_RECURSE sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
            ${path}*)
    set(${return} ${sources} PARENT_SCOPE)
endfunction(find_sources)

# Copies "files" to binaries of "project_name" on post build
function(copy_to_bin_on_build files project_name)
    foreach (file ${files})
        add_custom_command(TARGET ${project_name} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${PROJECT_SOURCE_DIR}/${file}"
                $<TARGET_FILE_DIR:${project_name}>)
    endforeach (file)
endfunction(copy_to_bin_on_build)



