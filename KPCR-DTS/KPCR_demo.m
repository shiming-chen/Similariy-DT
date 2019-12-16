% This is the demo script for the recently proposed algorithm 
% dynamic texture synthesis with kernel principal component regression (KPCR)

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
for k=1:N
    mov(k).cdata=read(video,k);
    newimage=double(rgb2gray(mov(k).cdata));
    newimage=imresize(newimage,[H1,W1]);
    Y(k,:)=reshape(newimage,[1,H1*W1]);
end
Y=Y./255;
Ym=mean(Y,1);
Y=Y-repmat(Ym,[N,1]);
XZ=Y(1:N-1,:);
XY=Y(2:N,:);
error_all=[];
%Training
for num_of_PC=50
    nv=30;
%     clear P_XZ W D Q K
[P_XZ,W,D,Q,K]=KPCA1(XZ,num_of_PC,'G',50,0); 
[n,p]=size(P_XZ);
M=eye(n)-ones(n,n)/n;
Mt=ones(n,n)/n;
% [nt,p]=size(XY);
D=D(1:p)'; 
% B=diag(1./D)*P_XZ'*XY; 
B=pinv(P_XZ)*XY;
XYnew=P_XZ*B;
KXYnew=Kernel_Test(XZ,XYnew,'G',50,0);
cen_KXYnew =(KXYnew - Mt*K)*M;
P_KXYnew=cen_KXYnew*Q;
Vhat=P_XZ(2:N-1,:)'-P_KXYnew(1:N-2,:)';
[Uv,Sv,Vv]=svd(Vhat,0);
Bhat=Uv(:,1:nv)*Sv(1:nv,1:nv)/sqrt(N-2);
%Synthesis
Y0=Y(1,:);
X0=P_XZ(1,:);
error=0;
newobj=VideoWriter('6kpcr.avi');
open(newobj);
Mt=ones(1,n)/n;
for num=1:1500
    Ynew=X0*B;
    KXnew=Kernel_Test(XZ,Ynew,'G',50,0);
    cen_KXnew =(KXnew - Mt*K)*M;
    P_Xnew=cen_KXnew*Q;
%     X0=P_Xnew+(Bhat*randn(nv,1))';
    X0=P_Xnew;
    newimage=Ynew+Ym;
    newimage( newimage<0)=0;
    newimage( newimage>1)=1;
    newimage=reshape(newimage,[H1,W1]);
    writeVideo(newobj,newimage);
end
error=error/(N-1);
error_all=[error_all,error];
close(newobj);
end