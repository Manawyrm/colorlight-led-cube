#!/bin/python3.7
import socket
import numpy as np
import mss

'''
Usage: python3.7 matrix_video_player.py
'''

UDP_IP = '192.168.178.50'
UDP_PORT = 26193

input_size = 1024    # input square size
offset_x = 0      # left offset
offset_y = 0      # top offset
color_scale = 8   # color divider

num_rows = 64
num_cols = num_rows
output_size = num_rows
bin_size = int(input_size / output_size)
fbuf = np.zeros((num_rows), dtype='i4')

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
monitor = {'top': offset_y, 'left': offset_x, 'width': input_size, 'height': input_size}

while(1):
    sct = mss.mss()
    cast = np.array(sct.grab(monitor), dtype='u4').reshape((output_size, bin_size, output_size, bin_size, 4)).max(3).max(1)
    sct.close()
    cast.astype(int)

    for y in range(num_rows):
        for x in range(num_cols):
            addr = ((y & 31) << 6) | (x & 63);

            r = cast[y][x][2].item()
            g = cast[y][x][0].item()
            b = cast[y][x][1].item()

            fbuf[x] = socket.htonl((addr << 18)     | ((((int(r)) & 0xFF) & 0xF8) << 11)
                                                    | ((((int(g)) & 0xFF) & 0xFC) << 5)
                                                    | ((((int(b)) & 0xFF) & 0xF8) >> 3))

        s.sendto(fbuf.tobytes(), (UDP_IP, UDP_PORT))

exit()
