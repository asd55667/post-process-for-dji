#!/bin/bash

# decrease video size
#SetFile -d '02/26/2025 11:00:00' ./making-lunch.mp4

# get create time of video input and store it in a global variable
CREATE_TIME=$(GetFileInfo -d $1)
echo $1 $CREATE_TIME

OUTPUT_FILE="${1%.*}-compressed.mp4"

# compress video
ffmpeg -i $1 -c:v libx264 -crf 28 -preset slow $OUTPUT_FILE

# set create time to video
SetFile -d "$CREATE_TIME"  $OUTPUT_FILE

# delete original video
rm $1

# rename output file
mv $OUTPUT_FILE $1