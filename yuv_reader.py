#!/usr/bin/python
from numpy import *
from PIL import Image 
from pprint import pprint
screenLevels = 255.0
 
         
def yuv_import(filename,dims,numfrm,startfrm):
    fp=open(filename,'rb')
    blk_size = prod(dims) *3/2
    fp.seek(blk_size*startfrm,0)
    Y=[]
    U=[]
    V=[]
    print dims[0]
    print dims[1]
    d00=dims[0]//2
    d01=dims[1]//2
    print d00
    print d01
    Yt=zeros((dims[0],dims[1]),uint8,'C')
    Ut=zeros((d00,d01),uint8,'C')
    Vt=zeros((d00,d01),uint8,'C')
    for i in range(numfrm):
        for m in range(dims[0]):
            for n in range(dims[1]):
                #print m,n
                Yt[m,n]=ord(fp.read(1))
        for m in range(d00):
            for n in range(d01):
                Ut[m,n]=ord(fp.read(1))
        for m in range(d00):
            for n in range(d01):
                Vt[m,n]=ord(fp.read(1))
        Y=Y+[Yt]
        U=U+[Ut]
        V=V+[Vt]
    fp.close()
    return (Y,U,V)

if __name__ == '__main__':
    fname = '/home/feng/work/project_01/yuv_files/waterfall_cif.yuv'
    data=yuv_import(fname, (288,352), 1, 3)
    #print data
    #im=array2image(array(data[0][0]))
    YY=data[0][0]
    YU=data[1][0]
    YV=data[2][0]
    print YY.shape
    for m in range(2):
        print m,': ', YY[m,:]
 
    #im=Image.frombytes('L',(288,352),YY.tostring())
    im=Image.frombytes('L',(352,288),YY.tostring())
    #im.show()
    im.save('f:\\a.jpg')

    pprint(data)
    pprint(YY)
    pprint(YY[0])
    pprint(YY[0][0])
    pprint(YY[1])
    s_l  = str(YY[0][0])
    s_l += str(YY[0][1] )
    s_l += str(YY[0][2] )
    s_l += str(YY[0][3])
    dim_x = 352
    dim_y = 288
    dim_ctu_x = (dim_x + 63) / 64
    dim_ctu_y = (dim_y + 63) / 64
    print('YY len is %d'%(len(YY)) )
    print('dim_ctu_x is %d' %dim_ctu_x)
    with open('new_exp', 'wb') as fh: 
      for ctu_y in range(dim_ctu_y): 
        for ctu_x in range(dim_ctu_x): 
          # Y
          for b8_y in range(8): 
            for b8_x in range(8): 
              for b4_y in range(2): 
                for b4_x in range(2): 
                  for j in range(4): 
                    for i in range(4): 
                      idx_x = ctu_x * 64 + b8_x * 8 + b4_x* 4 + i
                      idx_y = ctu_y * 64 + b8_y * 8 + b4_y* 4 + j
                      if idx_x >= len(YY[0]) or idx_y >= len(YY): 
                        fh.write(str('\0'))
                      else:
                        fh.write(YY[idx_y][idx_x])
          # U
          for b8_y in range(4): 
            for b8_x in range(4): 
              for b4_y in range(2): 
                for b4_x in range(2): 
                  for j in range(4): 
                    for i in range(4): 
                      idx_x = ctu_x * 32 + b8_x * 8 + b4_x* 4 + i
                      idx_y = ctu_y * 32 + b8_y * 8 + b4_y* 4 + j
                      if idx_x >= len(YY[0])/2 or idx_y >= len(YY)/2: 
                        fh.write(str('\0'))
                      else:
                        fh.write(YU[idx_y][idx_x])
     
          # V
          for b8_y in range(4): 
            for b8_x in range(4): 
              for b4_y in range(2): 
                for b4_x in range(2): 
                  for j in range(4): 
                    for i in range(4): 
                      idx_x = ctu_x * 32 + b8_x * 8 + b4_x* 4 + i
                      idx_y = ctu_y * 32 + b8_y * 8 + b4_y* 4 + j
                      if idx_x >= len(YY[0])/2 or idx_y >= len(YY)/2: 
                        fh.write(str('\0'))
                      else:
                        fh.write(YV[idx_y][idx_x])


#          print(ctu_x)
#      fh.write(YY[0][0])
#      fh.write(YY[0][1])
#      fh.write(YY[0][2])
#      fh.write(YY[0][3])
#      fh.write(YY[1][0])
#      fh.write(YY[1][1])
#      fh.write(YY[1][2])
#      fh.write(YY[1][3])
    fh.close()

