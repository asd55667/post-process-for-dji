#! /bin/bash

# DJI Action3 录制的视频文件名格式为 DJI_20250312161944_0001_D.MP4
# 需要按照日期创建文件夹，并把文件移动到对应的文件夹中
# 日期格式为 MM-DD


# 遍历当前目录下的所有文件
for file in *; do
    # 检查文件是否是视频文件
    if [[ $file == *.MP4 ]]; then
        # 获取文件名中的日期
        file_date=$(echo $file | sed -n 's/.*DJI_\([0-9]\{8\}\).*/\1/p')
        # 把日期格式转换为 MM-DD
        file_date="${file_date:4:2}-${file_date:6:2}"
        # 创建文件夹
        mkdir -p $file_date
        # 把文件移动到对应的文件夹中
        mv $file $file_date
    fi
done

