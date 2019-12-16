% This is the demo script for the algorithm dynamic texture synthesis with 
% fourier descriptors proposed in [1]. 

%  [1] B. Abraham, O. I. Camps, and M. Sznaier, ?Dynamic texture with fourier
% descriptors,?in Proceedings of the 4th nternational Workshop on Texture
% Analysisand Synthesis, 2005, pp. 53?8.

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
video=VideoReader('cflame.avi');
N=video.NumberOfFrames;
H=video.Height;
W=video.Width;
f=N;
Y=zeros(f,H*W);
error_all=[];
% Setting Parameters 
Thr = 90; 
%% 
n_fft_rgb_vec =50;
tau = N;  % The length of training sequence


im =read(video,1);
[a b c] = size(im); % Get the size of the frame
Y1=zeros(a*b,tau);
for i = 1:tau
    temp = double(rgb2gray(read(video,i))); 
    temp=temp./255;
    Y1(:,i)=temp(:);
    fft_temp_gray = fft2(temp);    
    %% 
    Y_fft(:,:,i) = fft_temp_gray(:);
    Y_gray(:,i) = temp(:);
end
Y_fft_gray = Y_fft(1:a*b,:);

%
thr_gray = 0;     
pp = Thr;
Mask_gray = ones(size(Y_fft_gray(:,1)));    
while(pp < nnz(Mask_gray)/numel(Mask_gray)*100 )
    thr_gray = thr_gray + 0.001;
    for j = 1:tau
        Mask_gray = Mask_gray & (abs(Y_fft_gray(:,j)) > thr_gray);
    end
end    
th_gray_vec = thr_gray;


thr_gray = th_gray_vec;
Mask_gray = ones(size(Y_fft_gray(:,1)));


for i = 1:tau    
    Mask_gray = Mask_gray & (abs(Y_fft_gray(:,i)) > thr_gray);
end
pos_gray = find(Mask_gray);
L_gray = length(pos_gray);

Y_fft_masked_gray = Y_fft_gray(pos_gray,:);
Y_SVD_gray(1:L_gray,:) = real(Y_fft_masked_gray);
Y_SVD_gray(L_gray+1:2*L_gray,:) = imag(Y_fft_masked_gray);

Y_SVD_Mean = mean(Y_SVD_gray,2);
[U,S,V] = svd(Y_SVD_gray-Y_SVD_Mean*ones(1,size(Y_SVD_gray,2)),0);            

% Obtain the $\hat{X},\hat{A},\hat{B},\hat{V}$                
n_fft = n_fft_rgb_vec;     
% nv_fft = round(n_fft/3*2);
nv_fft = 30;
first = 1:n_fft;
Chat = U(:,first); 
Xhat = S(first,first)*V(:,first)';
Ahat = Xhat(:,2:tau)*pinv(Xhat(:,1:tau-1));
Vhat = Xhat(:,2:tau)-Ahat*Xhat(:,1:(tau-1));
[Uv,Sv,Vv] = svd(Vhat,0);
Bhat = Uv(:,1:nv_fft)*Sv(1:nv_fft,1:nv_fft)/sqrt(tau-1);

% Synthesis the DT video based on 1st Order Markov Model and Linear Dynamic
% Model.

% Generate new frames using the last frame of training sample as the
% initial frame
X(:,1) = Xhat(:,1);
j = sqrt(-1);

syn_length = 1500; % 1500 frames are synthesized.
synth_Result(1:syn_length) = struct('frame', zeros(120, 160, 'uint8'));
newobj=VideoWriter('cflame_noise.avi');
open(newobj);
error=0;
% for t = 1:tau-1
for t = 1:1500
%     X(:,t+1) = Ahat*X(:,t) + Bhat*randn(nv_fft,1); 
     X(:,t+1) = Ahat*X(:,t);
    Y_res = Chat*X(:,t+1) + Y_SVD_Mean;
    Y_real_gray = Y_res(1:L_gray);
    Y_imag_gray = Y_res(L_gray + 1:2*L_gray);    
	Y_fft_synth = zeros(a*b,1);
    temp_gray = Y_real_gray + j*Y_imag_gray;
    Y_fft_synth(pos_gray) = temp_gray;        
    Y_synth_gray = real(ifft2(reshape(Y_fft_synth,a,b)));
    Y_synth_gray(Y_synth_gray>1)=1;
    Y_synth_gray(Y_synth_gray<0)=0;
    synth_Result(t).frame = Y_synth_gray;
    writeVideo(newobj,Y_synth_gray);
end
error=error/(N-1);
error_all=[error_all,error];
close(newobj);