# -*- coding: utf-8 -*-
#!/usr/bin/env python3

import os
import time



def delete_file_if_exists(file_path):
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"文件 {file_path} 已清除")

def cp_timestamp(digits=10):
    # 生成当前时间的时间戳，只有一个参数即时间戳的位数，默认为10位，输入位数即生成相应位数的时间戳，比如可以生成常用的13位时间戳
    timestamp = time.time()
    digits = 10**(digits - 10)
    timestamp = int(round(timestamp * digits))
    return timestamp