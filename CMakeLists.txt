cmake_minimum_required(VERSION 3.20)
project(RealityWin10PortClean LANGUAGES CXX)

if(NOT WIN32)
  message(FATAL_ERROR "This project targets 32-bit Windows. Configure with Visual Studio Win32/x86.")
endif()
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "Reality 1.5 and the original SSYNENG core are 32-bit. Select Win32/x86, not x64.")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_compile_definitions(WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
include_directories(
  ${CMAKE_SOURCE_DIR}/src/common
  ${CMAKE_SOURCE_DIR}/src/engine
  ${CMAKE_SOURCE_DIR}/src/compat
  ${CMAKE_SOURCE_DIR}/src/bridge
)

add_library(SSYNENG SHARED
  src/engine/host_cpu_accounting.cpp src/engine/host_cpu_accounting.h
  src/engine/voice_trace.cpp src/engine/voice_trace.h
  src/engine/ssyneng_dll.cpp
  src/bridge/reality_clap_bridge_engine.cpp src/bridge/reality_clap_bridge_engine.h
  src/bridge/reality_clap_bridge_shared.h
  src/engine/ssyneng_host.cpp src/engine/ssyneng_host.h
  src/engine/ioctl_router.cpp src/engine/ioctl_router.h
  src/engine/vmm_bridge.cpp src/engine/vmm_bridge.h
  src/engine/ssyneng_api.h
  src/common/log.cpp src/common/log.h
  src/engine/SSYNENG.def
)
target_link_libraries(SSYNENG PRIVATE kernel32 advapi32 user32)
set_target_properties(SSYNENG PROPERTIES OUTPUT_NAME "SSYNENG")

add_library(RealityCompat SHARED
  src/compat/reality_compat.cpp
  src/compat/native_midi.cpp src/compat/native_midi.h
  src/compat/midi_winmm.cpp src/compat/midi_winmm.h
  src/compat/audio_winmm.cpp src/compat/audio_winmm.h
  src/compat/virtual_registry.cpp src/compat/virtual_registry.h
  src/compat/synhigh_patch.cpp src/compat/synhigh_patch.h
  src/compat/seqplay_native.cpp src/compat/seqplay_native.h
  src/common/iathook.cpp src/common/iathook.h
  src/common/log.cpp src/common/log.h
  src/engine/ssyneng_api.h
  src/compat/RealityCompat.def
)
target_link_libraries(RealityCompat PRIVATE kernel32 user32 advapi32 winmm)
set_target_properties(RealityCompat PROPERTIES OUTPUT_NAME "RealityCompat")


# Native rewrite of the useful SSYNMIDI.DRV interface.  RealityCompat embeds
# the same core for in-process use; this separate DLL preserves the recovered
# driver entry-point surface for diagnostics and standalone testing.
add_library(SSYNMIDI32 SHARED
  src/ssynmidi32/ssynmidi32_dll.cpp
  src/compat/native_midi.cpp src/compat/native_midi.h
  src/common/log.cpp src/common/log.h
  src/engine/ssyneng_api.h
  src/ssynmidi32/SSYNMIDI32.def
)
target_link_libraries(SSYNMIDI32 PRIVATE kernel32 user32 winmm)
set_target_properties(SSYNMIDI32 PROPERTIES OUTPUT_NAME "SSYNMIDI32")

add_library(RTHUNK32 SHARED src/proxy/rthunk32.cpp src/proxy/RTHUNK32.def)
target_link_libraries(RTHUNK32 PRIVATE kernel32)
set_target_properties(RTHUNK32 PROPERTIES OUTPUT_NAME "RTHUNK32")

add_executable(RealityPortLauncher src/launcher/main.cpp)
target_link_libraries(RealityPortLauncher PRIVATE kernel32 user32)

add_custom_command(TARGET SSYNENG POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${CMAKE_SOURCE_DIR}/ssyneng.rehost"
          "$<TARGET_FILE_DIR:SSYNENG>/ssyneng.rehost")

if(EXISTS "${CMAKE_SOURCE_DIR}/Shared/SeerCC.dll")
  add_custom_command(TARGET RealityCompat POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:RealityCompat>/Shared"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/Shared/SeerCC.dll"
            "$<TARGET_FILE_DIR:RealityCompat>/Shared/SeerCC.dll")
endif()
