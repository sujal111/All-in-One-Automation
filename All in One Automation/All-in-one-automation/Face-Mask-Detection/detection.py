#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow as tf
import numpy as np
import cv2
from tensorflow.keras.models import load_model


# In[2]:


import keras


# In[3]:


model = load_model('my_model2')


# In[4]:


face_clsfr=cv2.CascadeClassifier('Data/haarcascade_frontalface_default.xml')
labels_dict={0:'MASK',1:'NO MASK'}
color_dict={0:(0,255,0),1:(0,0,255)}


# In[8]:


#vid = cv2.VideoCapture("rtsp://192.168.43.1:8080/video/h264")
vid = cv2.VideoCapture(0)
frame_width = int(vid.get(3))
frame_height = int(vid.get(4))

out = cv2.VideoWriter('output.mp4',cv2.VideoWriter_fourcc('M','P','4','V'), 25, (frame_width,frame_height))

while(True):
    ret, img = vid.read()
    faces=face_clsfr.detectMultiScale(img,1.3,10)

    if ret == True: 
        for (x,y,w,h) in faces:
            face_img=img[y:y+w,x:x+w]
            resized=cv2.resize(face_img,(150,150))
            normalized=resized/255.0
            reshaped=np.reshape(normalized,(1,150,150,3))
            result=model.predict(reshaped)
            label=np.argmax(result)
            cv2.rectangle(img,(x,y),(x+w,y+h),color_dict[label],2)
            cv2.rectangle(img,(x,y-40),(x+w,y),color_dict[label],-1)
            cv2.putText(img, labels_dict[label],
                        (x, y-10),cv2.FONT_HERSHEY_SIMPLEX,0.8,(255,255,255),2)

        out.write(img)

        cv2.imshow('frame',img)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    else:
        break  

vid.release()
out.release()

cv2.destroyAllWindows() 


# In[ ]:




