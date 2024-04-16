#verilog图像仿真用：jpg格式图像转txt格式
import cv2

img_path = "eye_in.jpg"       # 400x400
txt_path = "eye_in.txt"
img = cv2.imread(img_path)  # [BGR....],
img = cv2.resize(img, (640, 480))
# img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)  # [RGB....]
with open(txt_path, "w") as f:
    for i in range(img.shape[0]):  # 行
        for j in range(img.shape[1]):  # 列
            # for c in range(img.shape[2]):   # 通道
                # f.write('%02X' % img[i][j][c])  # 以固定格式写入
            f.write('%02X' % (img[i, j, 2]))  # 以固定格式写入,低位为R
            f.write('%02X' % (img[i, j, 1]))
            f.write('%02X' % (img[i, j, 0]))
            f.write("\n")

