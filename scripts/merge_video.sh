#!/bin/bash

# I want to merge all the related videos in the current directory into one video
# accept one argument, for example input is: `video-`, merge video with video-1, video-2, video-3, ...
# should check if video-1, video-2, video-3, ... exist
# if not, skip
# if exist, merge video util the last video

# check if the argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <video-prefix>"
    exit 1
fi

CREATE_TIME_OF_FIRST_VIDEO=$(date +%s)

# create a temp file to store the video list. file name is the should be unique, use timestamp
TEMP_VIDEO_LIST_FILE="temp_video_list_$(date +%s).txt"

# write all related video to the temp file
echo "start merge group $1"
for i in {1..10}; do
    # check if the video exist and is a mp4 file
    if [ -f "$1$i.mp4" ]; then
        echo "file $1$i.mp4" >> $TEMP_VIDEO_LIST_FILE
    
        if [ $i -eq 1 ]; then
            CREATE_TIME_OF_FIRST_VIDEO=$(GetFileInfo -d $1$i.mp4)
        fi

    else
        # echo "$1$i.mp4 not found"
        break
    fi
done

# merge all the videos in the temp file
echo "merge all the videos in the temp video list file"
echo "--------------------------------"
cat $TEMP_VIDEO_LIST_FILE
echo "--------------------------------"

# $1 is the video prefix, so the output video name
# should be $1 slice the last character
OUTPUT_VIDEO_NAME="${1%?}.mp4"

echo "output video name: $OUTPUT_VIDEO_NAME"

ffmpeg -f concat -safe 0 -i $TEMP_VIDEO_LIST_FILE -c copy $OUTPUT_VIDEO_NAME

# CREATE_TIME_OF_FIRST_VIDEO
echo "create time of first video: $CREATE_TIME_OF_FIRST_VIDEO"

# set create time to video
SetFile -d "$CREATE_TIME_OF_FIRST_VIDEO"  $OUTPUT_VIDEO_NAME

# remove the temp file
rm $TEMP_VIDEO_LIST_FILE

# clean the video fragment files
echo "clean the video fragment files"
for i in {1..10}; do
    if [ -f "$1$i.mp4" ]; then
        rm "$1$i.mp4"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to delete $1$i.mp4"
        else
            echo "$1$i.mp4 deleted successfully"
        fi
    fi
done

echo "done"