 mov=VideoReader('cflameslds.avi');
 length=mov.NumberOfFrames;
 for k=[1,20,80,200,400,800,1200]
     frame=read(mov,k);
     frame=rgb2gray(frame);
     frame=imresize(frame,[100,150]);
     imwrite(frame,strcat(num2str(k),'.jpg'),'jpg');
 end