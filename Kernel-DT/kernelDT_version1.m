% This is the demo script for the algorithm 
% kernel dynamic texture (kernel-DT) proposed in [1]. 

% [1] A. B. Chan and N. Vasconcelos, "Classifying video with kernel dynamic
% textures," in Computer Vision and Pattern Recognition, 2007. CVPR?7.
% IEEE Conference on. IEEE, 2007, pp. 1?.

% Please cite the following paper when using this code:
% Xinge You, Weigang Guo, Shujian Yu, Kan Li, Jose C. Principe, Dacheng Tao, 
% "Kernel Learning for Dynamic Texture Synthesis," 
% IEEE Transactions on Image Processing, accepted.
% 
% Notes
% For any questions, suggestions or cooperations, please feel free to contact Shujian Yu,
% yusjlcy9011@ufl.edu
% yusj9011@gmail.com

clear;
clc;
video=VideoReader('6.avi');
N=video.NumberOfFrames;
H=video.Height;
W=video.Width;
H1=100;
W1=150;
nv=30;
for k=1:N
    mov(k).cdata=read(video,k);
    newimage=double(rgb2gray(mov(k).cdata));
    newimage=imresize(newimage,[H1,W1]);
    Y(k,:)=reshape(newimage,[1,H1*W1]);
end
Y=Y./255;
Ym=mean(Y,1);
Y=Y-repmat(Ym,[N,1]);
[X, eigVector, eigValue]=kPCA(Y,50,'gaussian',8);
T=(X(1:N-1,:)'*X(1:N-1,:))\X(1:N-1,:)'*X(2:N,:);
Vhat=X(2:N,:)-X(1:N-1,:)*T;
Vhat=Vhat';
[Uv,Sv,Vv]=svd(Vhat,0);
Bhat=Uv(:,1:nv)*Sv(1:nv,1:nv)/sqrt(N-1);
X0=X(1,:);
newobj=VideoWriter('6kdt.avi');
open(newobj);
Xnew=[];
for t=1:N-1
%     X0=X0*T+(Bhat*randn(nv,1))';
    X0=X0*T;
    Xnew=[Xnew;X0];
    Yimage=Y(1,:)';
    Yimage=kPCA_PreImage(X0,eigVector,Y,8,Yimage);
    Yimage=Yimage+Ym';
    Yimage(Yimage<0)=0;
    Yimage(Yimage>1)=1;
    newimage=reshape(Yimage,[H1,W1]);
    writeVideo(newobj,newimage);
end
close(newobj);