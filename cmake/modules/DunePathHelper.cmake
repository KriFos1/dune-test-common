# Some helper functions for people developing the CMake build system
# to get quick and easy access to path variables of Dune modules.
#
# .. cmake_function:: dune_module_path
#
#    .. cmake_param:: MODULE
#       :single:
#       :required:
#
#       The name of the module.
#
#    .. cmake_param:: RESULT
#       :single:
#       :required:
#
#       The name of the variable to export the result.
#
#    .. cmake_param:: CMAKE_MODULES
#
#       Set to return the path to cmake modules
#
#    .. cmake_param:: BUILD_DIR
#
#       Set to return the path to the build directory
#
#    Returns the path to the source of the given module. This differs
#    whether it is called from the actual module, or from a module
#    requiring or suggesting this module.
#

function(dune_module_path)
  # Parse Arguments
  set(OPTION CMAKE_MODULES BUILD_DIR)
  set(SINGLE MODULE RESULT)
  set(MULTI)
  include(CMakeParseArguments)
  cmake_parse_arguments(PATH "${OPTION}" "${SINGLE}" "${MULTI}" ${ARGN})
  if(PATH_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed arguments in dune_module_path: This often indicates typos!")
  endif()

  # Check whether one and only one path type was set.
  set(OPTION_FOUND 0)
  foreach(opt ${OPTION})
    if(${PATH_${opt}})
      if(OPTION_FOUND)
        message(FATAL_ERROR "Cannot request two different paths from dune_module_path")
      else()
        set(OPTION_FOUND 1)
      endif()
    endif()
  endforeach()
  if(NOT OPTION_FOUND)
    message(FATAL_ERROR "Cannot determine type of requested path!")
  endif()

  # Set the requested paths for the cmake module path
  if(PATH_CMAKE_MODULES)
    set(IF_CURRENT_MOD ${CMAKE_SOURCE_DIR}/cmake/modules)
    set(IF_NOT_CURRENT_MOD ${${PATH_MODULE}_MODULE_PATH})
  endif()

  # Set the requested paths
  if(PATH_BUILD_DIR)
    set(IF_CURRENT_MOD ${CMAKE_BINARY_DIR})
    set(IF_NOT_CURRENT_MOD ${${PATH_MODULE}_DIR})
  endif()

  # Now set the path in the outer scope!
  if(CMAKE_PROJECT_NAME STREQUAL ${PATH_MODULE})
    set(${PATH_RESULT} ${IF_CURRENT_MOD} PARENT_SCOPE)
  else()
    set(${PATH_RESULT} ${IF_NOT_CURRENT_MOD} PARENT_SCOPE)
  endif()
endfunction()
