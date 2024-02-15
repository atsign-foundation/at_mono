cmake_minimum_required(VERSION 3.7 FATAL_ERROR)

# SRV DLL
set(S_NAME srv_dll)
project(${S_NAME} LANGUAGES C)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
include(${ROOT_DIR}/modules/misc/noports/packages/c/srv/CMakeLists.txt)

add_library(${S_NAME} SHARED
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/srv.def>
  $<INSTALL_INTERFACE:srv.def>
  ${SRV_SRCS}
)

set_target_properties(${S_NAME} PROPERTIES
  SOVERSION 1
  OUTPUT_NAME "srv"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "$ENV{XCODE_CODE_SIGN_IDENTITY}"
)

target_link_libraries(${S_NAME} PUBLIC
  atchops::atchops
  MbedTLS::mbedcrypto
  atchops::uuid4-static
  srv_lib
)
