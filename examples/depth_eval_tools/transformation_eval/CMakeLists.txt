# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

find_package(OpenCV REQUIRED)
include_directories(
    .
	../kahelpers/
	../kahelpers/inc/
	)

add_executable(transformation_eval
    transformation_eval.cpp
	../kahelpers/kahelpers.cpp
	../kahelpers/inc/kahelpers.h
	)

target_link_libraries(transformation_eval PRIVATE
    k4a::k4a
	k4a::k4arecord
    ${OpenCV_LIBS}
	)