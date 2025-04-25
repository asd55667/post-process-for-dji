# Record of my daily life

## Equipment

- DJI Action3
- TELESIN U Shape Neck Holder Mount 2.0

## Problems

### Video File Size

By default, video captured with `HEVC` codec, it will take a huge storage for disk, and cost very long time and big throughout. So video Remuxing is important, I decide to change codec to `H264`, and with a big `crf`.

> Implementation with `compress_video.sh`

### Video File Chunks

Camera will divide long video with chunks, the largest file size of each `MP4` file is `3.77GB` with duration `24:06`.

So, I need to merge a 1h duration with 3 chunk files to restore the original video.

Which videos should be merged?

I need to add extra description to help `script` know that. My strategy is to rename these files manually with suffix, such as `name-1.mp4`, `name-2.mp4` ... `name-10.mp4`, the battery of camera can only support recording with nearly 2h at most.

> Implementation with `merge_video.sh`

### Video Created Time

After compressing or merging video files, the original created time has been changed. I wish it could keep the same created time so that I could track when it initiates and how long it takes and synchronize to logs.

## Procedure of Post Process

Video record with date. After transferring to mac, and then executing the scripts.

- Categorize videos with date. `orgnize_videos.sh`
- Rename filename for every mp4 file. (Manually)
- merge and compress every mp4 file. `merge_and_compress.sh`
