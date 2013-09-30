# cmake build configuration for v^3
# (c) by Stefan Roettger

OPTION(FIND_DCMTK_MANUALLY "Do not rely on CMake to find DCMTK." OFF)

# path to custom cmake modules
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMakeModules;${CMAKE_MODULE_PATH}")

# volren library name
IF (WIN32)
   SET(VOLREN_NAME "libVolRen")
ELSE (WIN32)
   SET(VOLREN_NAME "VolRen")
ENDIF (WIN32)

# viewer library name
IF (WIN32)
   SET(VIEWER_NAME "libViewer")
ELSE (WIN32)
   SET(VIEWER_NAME "Viewer")
ENDIF (WIN32)

# path to volren library
IF (NOT VOLREN_PATH)
   SET(VOLREN_PATH $ENV{VOLREN_PATH})
   IF (NOT VOLREN_PATH)
      FIND_PATH(VOLREN_PATH volren.h PATHS ${CMAKE_CURRENT_SOURCE_DIR} volren)
   ENDIF (NOT VOLREN_PATH)
ENDIF (NOT VOLREN_PATH)

# path to viewer
IF (NOT VIEWER_PATH)
   SET(VIEWER_PATH $ENV{VIEWER_PATH})
   IF (NOT VIEWER_PATH)
      FIND_PATH(VIEWER_PATH guibase.h ${CMAKE_CURRENT_SOURCE_DIR})
   ENDIF (NOT VIEWER_PATH)
ENDIF (NOT VIEWER_PATH)

# gcc version
IF (CMAKE_COMPILER_IS_GNUCXX)
   EXEC_PROGRAM(${CMAKE_CXX_COMPILER} ARGS --version OUTPUT_VARIABLE _compiler_output)
   STRING(REGEX REPLACE ".*([0-9]\\.[0-9]\\.[0-9]).*" "\\1" GCC_COMPILER_VERSION ${_compiler_output})
   MESSAGE(STATUS "gcc version: ${GCC_COMPILER_VERSION}")
ENDIF (CMAKE_COMPILER_IS_GNUCXX)

# default Unix compiler definitions
IF (NOT CMAKE_BUILD_TYPE)
   IF (UNIX)
      SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -finline-functions -Wall -Wno-unused-parameter -Wno-parentheses")
      IF (NOT GCC_COMPILER_VERSION VERSION_LESS "4.4.1")
         SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-result")
      ENDIF (NOT GCC_COMPILER_VERSION VERSION_LESS "4.4.1")
   ENDIF (UNIX)
ENDIF (NOT CMAKE_BUILD_TYPE)

# build type
IF (CMAKE_BUILD_TYPE)
   STRING(TOUPPER ${CMAKE_BUILD_TYPE} VIEWER_BUILD_TYPE)
ELSE (CMAKE_BUILD_TYPE)
   SET(VIEWER_BUILD_TYPE DEFAULT)
ENDIF (CMAKE_BUILD_TYPE)
MESSAGE(STATUS VIEWER_BUILD_TYPE=${VIEWER_BUILD_TYPE})

# platform definitions
IF (UNIX)
   ADD_DEFINITIONS(-DLINUX)
ENDIF (UNIX)
IF (APPLE)
   ADD_DEFINITIONS(-DMACOSX)
ENDIF (APPLE)
IF (WIN32)
   ADD_DEFINITIONS(-DWINOS)
ENDIF (WIN32)

# Windows compiler definitions
IF (MSVC)
   ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE)
   SET(CMAKE_CXX_FLAGS_DEBUG "/MTd /Z7 /Od")
   SET(CMAKE_CXX_FLAGS_RELEASE "/MT /O2")
   SET(CMAKE_CXX_STANDARD_LIBRARIES "wsock32.lib netapi32.lib")
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4244 /wd4305")
ENDIF (MSVC)

# check environment variable for third party directory
IF (NOT VIEWER_THIRDPARTY_DIR)
   SET(VIEWER_THIRDPARTY_DIR $ENV{VIEWER_THIRDPARTY_DIR})
ENDIF (NOT VIEWER_THIRDPARTY_DIR)

MACRO(SET_VIEWER_PATH name subdir)
   SET(${name} ${VIEWER_PATH}
               ${VIEWER_PATH}/..
               ${VIEWER_PATH}/../..
               ${VIEWER_PATH}/${subdir}
               ${VIEWER_PATH}/../${subdir}
               ${VIEWER_PATH}/../deps/${subdir}
               ${VIEWER_PATH}/../../${subdir}
               ${VIEWER_PATH}/../libmini/deps/${subdir}
               ${VIEWER_PATH}/../../libmini/deps/${subdir}
               /usr/local/${subdir} /usr/local /usr
               /usr/include/${subdir}
               ${VIEWER_PATH}/../WIN32/${subdir}
               ${VIEWER_PATH}/../libmini/WIN32/${subdir}
               ${VIEWER_PATH}/../../libmini/WIN32/${subdir})
   IF (VIEWER_THIRDPARTY_DIR)
      SET(${name} ${${name}}
                  ${VIEWER_THIRDPARTY_DIR}
                  ${VIEWER_THIRDPARTY_DIR}/${subdir}
                  ${VIEWER_THIRDPARTY_DIR}/deps/${subdir}
                  /usr/local/${subdir} /usr/local /usr
                  /usr/include/${subdir}
                  ${VIEWER_THIRDPARTY_DIR}/WIN32/${subdir})
   ENDIF (VIEWER_THIRDPARTY_DIR)
ENDMACRO(SET_VIEWER_PATH)

# paths to dependencies
SET_VIEWER_PATH(MINI_PATH mini)
SET_VIEWER_PATH(ZLIB_PATH zlib)
SET_VIEWER_PATH(DCMTK_PATH dicom)
SET_VIEWER_PATH(FREEGLUT_PATH freeglut)

# paths to WIN32 dependencies
SET_VIEWER_PATH(WIN32_MINI_PATH mini)
SET_VIEWER_PATH(WIN32_ZLIB_PATH zlib)
SET_VIEWER_PATH(WIN32_DCMTK_PATH dcmtk)
SET_VIEWER_PATH(WIN32_FREEGLUT_PATH freeglut)

MACRO(FIND_VIEWER_LIBRARY name file path)
   IF (NOT ${name})
      IF (NOT VIEWER_BUILD_TYPE MATCHES DEBUG)
         FIND_LIBRARY(${name} ${file} PATHS ${path} PATH_SUFFIXES lib release minsizerel relwithdebinfo NO_DEFAULT_PATH)
         FIND_LIBRARY(${name} ${file} PATHS ${path} PATH_SUFFIXES lib release minsizerel relwithdebinfo)
      ELSE (NOT VIEWER_BUILD_TYPE MATCHES DEBUG)
         FIND_LIBRARY(${name} NAMES ${file}d ${file} PATHS ${path} PATH_SUFFIXES lib debug NO_DEFAULT_PATH)
         FIND_LIBRARY(${name} NAMES ${file}d ${file} PATHS ${path} PATH_SUFFIXES lib debug)
      ENDIF (NOT VIEWER_BUILD_TYPE MATCHES DEBUG)
   ENDIF (NOT ${name})
ENDMACRO(FIND_VIEWER_LIBRARY)

MACRO(FIND_VIEWER_LIBRARY2 name file path1 path2)
   FIND_VIEWER_LIBRARY(${name} ${file} "${path1}")
   FIND_VIEWER_LIBRARY(${name} ${file} "${path2}")
ENDMACRO(FIND_VIEWER_LIBRARY2)

MACRO(FIND_VIEWER_PATH name file path)
   IF (NOT ${name})
      FIND_PATH(${name} ${file} PATHS ${path} PATH_SUFFIXES include NO_DEFAULT_PATH)
      FIND_PATH(${name} ${file} PATHS ${path} PATH_SUFFIXES include)
   ENDIF (NOT ${name})
ENDMACRO(FIND_VIEWER_PATH)

MACRO(FIND_VIEWER_PATH2 name file path1 path2)
   FIND_VIEWER_PATH(${name} ${file} "${path1}")
   FIND_VIEWER_PATH(${name} ${file} "${path2}")
ENDMACRO(FIND_VIEWER_PATH2)

# find volren dependency
FIND_VIEWER_LIBRARY(VOLREN_LIBRARY ${VOLREN_NAME} ${VOLREN_PATH})
IF (NOT VOLREN_LIBRARY)
   SET(VOLREN_LIBRARY ${VOLREN_NAME})
ENDIF (NOT VOLREN_LIBRARY)
FIND_VIEWER_PATH(VOLREN_INCLUDE_DIR volren.h ${VOLREN_PATH})
INCLUDE_DIRECTORIES(${VOLREN_INCLUDE_DIR})

# find viewer dependency
FIND_VIEWER_LIBRARY(VIEWER_LIBRARY ${VIEWER_NAME} ${VIEWER_PATH})
IF (NOT VIEWER_LIBRARY)
   SET(VIEWER_LIBRARY ${VIEWER_NAME})
ENDIF (NOT VIEWER_LIBRARY)
FIND_VIEWER_PATH(VIEWER_INCLUDE_DIR guibase.h ${VIEWER_PATH})
INCLUDE_DIRECTORIES(${VIEWER_INCLUDE_DIR})

# find libmini library
FIND_PACKAGE(MINI)

# determine libmini status
IF (MINI_FOUND)
   INCLUDE_DIRECTORIES(${MINI_INCLUDE_DIR})
   ADD_DEFINITIONS(-DHAVE_MINI)
ENDIF (MINI_FOUND)

# find DCMTK dependencies
# caution: when using a cmake built dcmtk library on WIN32,
#          make sure that the option DCMTK_OVERWRITE_WIN32_COMPILER_FLAGS is OFF.
#          otherwise dcmtk is built with /MT and not as usual with the cmake default /MD.
#          this will conflict with the /MD setting of this project.
IF (FIND_DCMTK_MANUALLY)
   FIND_VIEWER_LIBRARY2(DCMTK_ofstd_LIBRARY ofstd "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_oflog_LIBRARY oflog "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_dcmdata_LIBRARY dcmdata "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_dcmjpeg_LIBRARY dcmjpeg "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_ijg8_LIBRARY ijg8 "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_ijg12_LIBRARY ijg12 "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_ijg16_LIBRARY ijg16 "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_LIBRARY2(DCMTK_dcmtls_LIBRARY dcmtls "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
   FIND_VIEWER_PATH2(DCMTK_INCLUDE_DIR dcmtk/dcmdata/dctk.h "${DCMTK_PATH}" "${WIN32_DCMTK_PATH}")
ELSE (FIND_DCMTK_MANUALLY)
   FIND_PATH(DCMTK_DIR include/dcmtk/config/osconfig.h PATHS /usr/local /usr/local/dcmtk ../dcmtk ../../dcmtk)
   FIND_PACKAGE(DCMTK)
ENDIF (FIND_DCMTK_MANUALLY)

# determine DCMTK status
IF (DCMTK_FOUND)
   INCLUDE_DIRECTORIES(${DCMTK_INCLUDE_DIR})
   IF (NOT WIN32)
      ADD_DEFINITIONS(-DHAVE_CONFIG_H)
   ENDIF (NOT WIN32)

   # find threads library
   FIND_PACKAGE(Threads)

   # find ZLIB dependency
   FIND_VIEWER_LIBRARY(ZLIB_LIBRARY z "${ZLIB_PATH}")
   FIND_VIEWER_LIBRARY(ZLIB_LIBRARY zlib "${WIN32_ZLIB_PATH}")
   FIND_VIEWER_PATH2(ZLIB_INCLUDE_DIR zlib.h "${ZLIB_PATH}" "${WIN32_ZLIB_PATH}")
   INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR})

   ADD_DEFINITIONS(-DHAVE_DCMTK)
ENDIF (DCMTK_FOUND)

# find OpenGL dependency
FIND_PACKAGE(OpenGL)
IF (NOT OPENGL_LIBRARIES)
   SET(OPENGL_LIBRARIES ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY})
ENDIF (NOT OPENGL_LIBRARIES)

# find GLUT dependency
IF (WIN32)
   FIND_VIEWER_LIBRARY(GLUT_LIBRARY freeglut_static "${WIN32_FREEGLUT_PATH}")
   FIND_VIEWER_PATH(GLUT_INCLUDE_DIR GL/glut.h "${WIN32_FREEGLUT_PATH}")
ELSE (WIN32)
   FIND_PACKAGE(GLUT)
   IF (NOT GLUT_LIBRARY OR NOT GLUT_INCLUDE_DIR)
      FIND_VIEWER_LIBRARY(GLUT_LIBRARY glut "${FREEGLUT_PATH}")
      FIND_VIEWER_PATH(GLUT_INCLUDE_DIR GL/glut.h "${FREEGLUT_PATH}")
   ENDIF (NOT GLUT_LIBRARY OR NOT GLUT_INCLUDE_DIR)
   IF (NOT GLUT_LIBRARY)
      SET(GLUT_LIBRARY glut)
   ENDIF (NOT GLUT_LIBRARY)
   IF (NOT GLUT_INCLUDE_DIR)
      SET(GLUT_INCLUDE_DIR /usr/include/GL)
   ENDIF (NOT GLUT_INCLUDE_DIR)
ENDIF (WIN32)
INCLUDE_DIRECTORIES(${GLUT_INCLUDE_DIR})
IF (WIN32)
   ADD_DEFINITIONS(-DFREEGLUT_STATIC)
ENDIF (WIN32)

# check for debug build
IF (VIEWER_BUILD_TYPE MATCHES DEBUG)
   ADD_DEFINITIONS(-DVIEWER_DEBUG)
ENDIF (VIEWER_BUILD_TYPE MATCHES DEBUG)

# check for release build
IF (VIEWER_BUILD_TYPE MATCHES RELEASE)
   ADD_DEFINITIONS(-DVIEWER_RELEASE)
ENDIF (VIEWER_BUILD_TYPE MATCHES RELEASE)

MACRO(MAKE_VIEWER_EXECUTABLE name)
   ADD_EXECUTABLE(${name} ${name}.cpp)
   TARGET_LINK_LIBRARIES(${name}
      ${VIEWER_NAME}
      ${VOLREN_NAME}
      ${OPENGL_LIBRARIES}
      ${GLUT_LIBRARY}
      )
   IF (MINI_FOUND)
      TARGET_LINK_LIBRARIES(${name}
         ${MINI_LIBRARIES}
         )
   ENDIF (MINI_FOUND)
   IF (DCMTK_FOUND)
      IF (FIND_DCMTK_MANUALLY)
         TARGET_LINK_LIBRARIES(${name}
            ${DCMTK_dcmdata_LIBRARY}
            ${DCMTK_dcmjpeg_LIBRARY}
            ${DCMTK_ijg8_LIBRARY}
            ${DCMTK_ijg12_LIBRARY}
            ${DCMTK_ijg16_LIBRARY}
            ${DCMTK_dcmtls_LIBRARY}
            ${DCMTK_oflog_LIBRARY}
            ${DCMTK_ofstd_LIBRARY}
            ${ZLIB_LIBRARY}
	    ${CMAKE_THREAD_LIBS_INIT}
            )
      ELSE (FIND_DCMTK_MANUALLY)
         TARGET_LINK_LIBRARIES(${name}
            ${DCMTK_LIBRARIES}
            ${ZLIB_LIBRARY}
	    ${CMAKE_THREAD_LIBS_INIT}
            )
      ENDIF (FIND_DCMTK_MANUALLY)
   ENDIF (DCMTK_FOUND)
ENDMACRO(MAKE_VIEWER_EXECUTABLE)
