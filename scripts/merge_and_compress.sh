#!/bin/bash

# Script to:
# 1. Find videos that match pattern filename-1, filename-2, etc. and merge them
# 2. Convert HEVC videos to h264 using compress_video.sh

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPRESS_SCRIPT="$SCRIPT_DIR/compress_video.sh"
MERGE_SCRIPT="$SCRIPT_DIR/merge_video.sh"

# Check if the required scripts exist
if [ ! -f "$COMPRESS_SCRIPT" ]; then
    echo "Error: compress_video.sh not found at $COMPRESS_SCRIPT"
    exit 1
fi

if [ ! -f "$MERGE_SCRIPT" ]; then
    echo "Error: merge_video.sh not found at $MERGE_SCRIPT"
    exit 1
fi

# Make sure the scripts are executable
chmod +x "$COMPRESS_SCRIPT" "$MERGE_SCRIPT"

# Function to check if a video has HEVC codec
is_hevc() {
    local video_file="$1"
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video_file")
    if [[ "$codec" == "hevc" ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}

# Function to process a directory
process_directory() {
    local dir="$1"
    echo "Processing directory: $dir"
    echo '--------------------------------'
    
    # Step 1: Find and merge videos with pattern filename-1, filename-2, etc.
    # Find unique prefixes by removing the numbers at the end
    local prefixes=()
    for video in "$dir"/*.MP4; do
        if [[ ! -f "$video" ]]; then
            continue
        fi

        echo "Processing video: $video"
        
        # Extract base name without extension
        local basename=$(basename "$video" .MP4)
        
        # Check if the basename matches the pattern filename-X where X is a number
        if [[ "$basename" =~ (.*)-([0-9]+)$ ]]; then
            local prefix="${BASH_REMATCH[1]}-"
            if [[ ! " ${prefixes[@]} " =~ " ${prefix} " ]]; then
                prefixes+=("$prefix")
            fi
        fi
    done
    
    # Process each prefix
    for prefix in "${prefixes[@]}"; do
        echo "Found group with prefix: $prefix"
        local first_file="${prefix}1.mp4"
        if [[ -f "$dir/$first_file" ]]; then
            echo "Merging videos with prefix $prefix"
            (cd "$dir" && "$MERGE_SCRIPT" "$prefix")
            
            # The merged file will be named prefix without the trailing dash + .mp4
            local merged_file="${prefix%?}.mp4"
            if [[ -f "$dir/$merged_file" ]]; then
                echo "Compressing merged file: $merged_file"
                (cd "$dir" && "$COMPRESS_SCRIPT" "$merged_file")
            fi
        fi
    done
    
    # Step 2: Process remaining individual video files with HEVC codec
    for video in "$dir"/*.MP4; do
        if [[ ! -f "$video" ]]; then
            continue
        fi
        
        # Skip files that were part of the merge process
        local basename=$(basename "$video" .MP4)
        local skip=false
        
        for prefix in "${prefixes[@]}"; do
            if [[ "$basename" =~ ^${prefix%?}$ || "$basename" =~ ^${prefix}[0-9]+$ ]]; then
                skip=true
                break
            fi
        done
        
        if [[ "$skip" == "true" ]]; then
            continue
        fi
        
        # Check if the video has HEVC codec
        if is_hevc "$video"; then
            echo "Converting HEVC video to h264: $video"
            (cd "$dir" && "$COMPRESS_SCRIPT" "$(basename "$video")")
        fi
    done
    
    # Process subdirectories recursively
    for subdir in "$dir"/*/; do
        if [[ -d "$subdir" ]]; then
            process_directory "$subdir"
        fi
    done
}

# Start processing from the current directory
current_dir="$(pwd)"
process_directory "$current_dir"

echo "All videos processed successfully!"
