% This is the demo script for the algorithm dynamic texture synthesis with 
% linear dynamic system proposed in [1]. 

% [1] G. Doretto, A. Chiuso, Y. Wu, and S. Soatto, “Dynamic textures,”
% International Journal of Computer Vision, vol. 51, no. 2, pp. 91–109,
% 2003.

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

f=N;
Y=zeros(f,H*W);
error_all=[];
for k=1:f
    mov(k).cdata=read(video,k);
    image=rgb2gray(mov(k).cdata);     
    Y(k,:)=reshape(image,[1,H*W]);
end
Y=Y';
Y=Y./255;
Y=double(Y);
tau=size(Y,2);Ymean=mean(Y,2);
[U,S,V]=svd((Y-Ymean*ones(1,tau)),0);
for n=50
X=zeros(n,N);
nv=30;
Chat=U(:,1:n);Xhat=S(1:n,1:n)*V(:,1:n)';
x0=Xhat(:,1);
Ahat=Xhat(:,2:tau)*pinv(Xhat(:,1:(tau-1)));
Vhat=Xhat(:,2:tau)-Ahat*Xhat(:,1:(tau-1));
[Uv,Sv,Vv]=svd(Vhat,0);
Bhat=Uv(:,1:nv)*Sv(1:nv,1:nv)/sqrt(tau-1);
X(:,1)=x0;
I=zeros(W*H,tau);
%
newobj=VideoWriter('6lds.avi');
open(newobj);

error=0;
for t=2:1200
    X(:,t)=Ahat*X(:,t-1);
    I(:,t)=Chat*X(:,t)+Ymean;
    newimage=(reshape(I(:,t),[H,W]));
     newimage(newimage<0)=0;
     newimage(newimage>1)=1;
     writeVideo(newobj,newimage);
end
error=error/(N-1);
error_all=[error_all,error];
close(newobj);
end