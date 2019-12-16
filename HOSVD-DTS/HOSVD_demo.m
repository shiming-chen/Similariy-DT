% This is the demo script for the algorithm HOSVD proposed in [1]. Since
% the original algorithm is designed for RGB video, we use the RGB DT
% sequence for training and convert the synthesized video to GRAY for
% comparison.

% Reference:
%  [1] R. Costantini, L. Sbaiz, S. Susstrunk, Higher order svd analysis for
%  dynamic texture synthesis, Image Processing, IEEE Transactions on 17 (1)
%  (2008) 42-52.



clear;
clc;

% Add path for Tensor Toolbox V1.0
addpath('TensorToolbox_V1.0');
video=VideoReader('/home/ooxx/Videos/DT1/flame_original.mpg');
N=video.NumberOfFrames;
H1=video.Height;
W1=video.Width;
% Setting Parameters 
texture_name = 1;  % Choose the DT sequence for testing, set as 1,2,3,4
tau = N; % Length of the training samples
r3 = 40; % The dimension of the subspace for the space domain 
r1 = 200; % The dimension of the subspace for the time domain 


im =read(video,1);
[a b c] = size(im); % Get the size of the frame

% Save the DT sequence data as a tensor
Y = zeros(a,b,tau,c);
Y1=zeros(a*b,tau);
for i = 1:tau  
   temp = double(read(video,i));  
   temp=temp./255;
   temp1=rgb2gray(temp);
   Y1(:,i)=temp1(:);
    Y(:,:,i,1) = temp(:,:,1);
    Y(:,:,i,2) = temp(:,:,2);
    Y(:,:,i,3) = temp(:,:,3);
end
Yt = tensor(Y);

% Decompose the tensor using SVD
[Ur,~,~] = svds(double(tensor_as_matrix(Yt,1)),a);
[Vr,~,~] = svds(double(tensor_as_matrix(Yt,2)),b);
[Fr,~,~] = svds(double(tensor_as_matrix(Yt,3)),tau);
[Wr,~,~] = svds(double(tensor_as_matrix(Yt,4)),3);             

% Obtain the subspace
[I J K L] = size(Y);
Yt = tensor(Y);
r = [min(r1,a) min(r1,b) r3 3];
U = Ur(:,1:r(1));
V = Vr(:,1:r(2));
F = Fr(:,1:r(3));
W = Wr(:,1:r(4));

% Obtain the $\hat{X},\hat{A},\hat{B},\hat{V}$
Xhat = F'; 
Ahat = Xhat(:,2:tau)*pinv(Xhat(:,1:tau-1)); 
Vhat = Xhat(:,2:tau)-Ahat*Xhat(:,1:(tau-1)); 
n = size(Ahat,1);
% nv = round(n/3*2);  

nv = 15;
[Uv,Sv,Vv] = svd(Vhat,0);
Bhat = Uv(:,1:nv)*Sv(1:nv,1:nv)/(tau-1);



% Synthesis the DT video based on 1st Order Markov Model and Linear Dynamic
% Model. 
S = ttm(Yt,{U',V',F',W'});  
syn_length = 1500; % 1500 frames are synthesized.


% Generate new frames using the last frame of training sample as the
% initial frame
X(:,1) = Xhat(:,1);

% Calculate the dynamic trajectory of the DT sequence in the subspace
for t = 1:1500
% X(:,t+1) = Ahat*X(:,t) + Bhat*randn(nv,1);
X(:,t+1) = Ahat*X(:,t);
end      



newobj=VideoWriter('cflameHOSVD.avi');
open(newobj);
F = X'; 

B = tucker_tensor(S,{U,V,F,W});
core = tensor(B.lambda);
Yp = ttm(core, {U,V,F,W});
YpM1 = tensor_as_matrix(Yp,3);
for k = 2:1500          
    imm_pred = reshape(YpM1(k,:),a,b,c);
    frame=rgb2gray(imm_pred);
    frame(frame<0)=0;
    frame(frame>1)=1;
    writeVideo(newobj,frame);
end
close(newobj);