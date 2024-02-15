cmake_minimum_required(VERSION 3.7 FATAL_ERROR)

# ATCHOPS DLL
set(P_NAME atchops_dll)
project(${P_NAME} LANGUAGES C)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
include(${ROOT_DIR}/modules/c/at_c/packages/atchops/CMakeLists.txt)

add_library(${P_NAME} SHARED
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/atchops.def>
  $<INSTALL_INTERFACE:atchops.def>
  ${ATCHOPS_SOURCES}
)

set_target_properties(${P_NAME} PROPERTIES
  SOVERSION 1
  OUTPUT_NAME "atchops"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "$ENV{XCODE_CODE_SIGN_IDENTITY}"
)

target_link_libraries(${P_NAME} PUBLIC
  atchops::atchops
  MbedTLS::mbedcrypto
  uuid4::uuid4-static
)
