#verilog图像仿真用：txt格式图像转jpg格式
import cv2
import numpy as np

def read_txt(path):
    """
    读取txt文件，返回txt_data
    """
    with open(path, 'rb') as f:
        # 文件在with语句块结束时自动关闭
        data = [(int(line.strip(), 16)) for line in f]    # strip()用于去除每行末尾的换行符
    return data

def list2mat(h,w,c,list_data):#高，宽，通道
    img_array = np.zeros((h, w, c), dtype=np.uint8)
    for i in range(h):
        for j in range(w):
            img_array[i, j, 0] = (list_data[i * w + j] & 0x00_00_ff) >> 0       # R
            img_array[i, j, 1] = (list_data[i * w + j] & 0x00_ff_00) >> 8       # G
            img_array[i, j, 2] = (list_data[i * w + j] & 0xff_00_00) >> 16      # B
    return img_array

img_path = "output.jpg"       # 400x400
txt_path = "data_out.txt"
IMG_W = 640
IMG_H = 480
IMG_C = 3
data_list = read_txt(txt_path)
img_array = list2mat(IMG_H, IMG_W, IMG_C, data_list)    # txt文件里面，低位为R
cv2.imshow('Image', img_array)
cv2.waitKey(0)
