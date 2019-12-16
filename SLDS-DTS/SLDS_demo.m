% This is the demo script for the algorithm dynamic texture synthesis with
% stable linear dynamic system proposed in [1].

% [1] S. M. Siddiqi, B. Boots, and G. J. Gordon, "A constraint generation
% approach to learning stable linear dynamical systems," DTIC Document,
% Tech. Rep., 2008.

% Please cite the following paper when using this code:
% Xinge You, Weigang Guo, Shujian Yu, Kan Li, Jose C. Principe, Dacheng Tao, 
% "Kernel Learning for Dynamic Texture Synthesis," 
% IEEE Transactions on Image Processing, accepted.
% 
% Notes
% For any questions, suggestions or cooperations, please feel free to contact Shujian Yu,
% yusjlcy9011@ufl.edu
% yusj9011@gmail.com

% Subspace Identification Parameters
n = 50;
d = 1;
algo = 1;

% Video Parameters
frames = 1500;
framesPerSec = 24;
inputFile  = '6.avi';
outputFile = '6slds.avi';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Import avi
video = VideoReader(inputFile);
num = video.NumberOfFrames;
height = video.Height;
width = video.Width;

% mov = read(mov);
Y=zeros(height*width,num);
for i=1:num
    mov(i).cdata=read(video,i);
    image=rgb2gray(mov(i).cdata);     
    Y(:,i)=reshape(image,[height*width,1]);
end
% Y=Y';
Y=Y./255;


% Learn a Linear Dynamical System (LDS) from Data
[Ahat, Chat, Qhat, Rhat, Xhat, Ymean] = learnLDS(Y, n, d, algo);


% Simulate a Video from LDS
% aviobj = avifile(outputFile,'fps',framesPerSec,'compression','none');
newobj=VideoWriter(outputFile);
open(newobj);

X = zeros(size(Xhat,1), frames);
X(:,1) = Xhat(:,1);
error=0;

% graylong = [(0:255)' (0:255)' (0:255)']/255;
for frameIndex = 1:num-1
%     X(:,frameIndex+1) = Ahat*X(:,frameIndex) + mvnrnd(zeros(1,n), Qhat)';
  X(:,frameIndex+1) = Ahat*X(:,frameIndex);
  I=Chat*X(:,(frameIndex+1))+Ymean;
  error1=(norm(I-Y(:,frameIndex+1)))^2;
  error=error+error1;
  I(I<0)=0;
  I(I>1)=1;
  f = reshape(I,[height, width]);
  writeVideo(newobj,f);
end
error=error/(num-1);
close(newobj);