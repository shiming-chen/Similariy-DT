%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is used for generating dynamic textures with RGB

%%%%    AUTHOR:         Dr. Shiming Chen
%%%%    ORGANIZATION    Huazhong University of Science and Technology (HUST), China
%%%%    EMAIL:          shimingchen@hust.edu.cn
%%%%    WEBSITE:        https://shiming-chen.github.io
%%%%    DATE:           November 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function similarity_RGB(filename, savename)
 %filename is the training DT 
 %savename is the name of generated DT video 


kernel_type='RBF_kernel';                 %kernel_type is used for the selection of kernel type, default:"Gaussian kernel"
kernel_coefficient=2^8;                   %kernel_coefficient is used for the selection of kernel coefficienr, default:"2^8"
regularization_factor=2^-10;              %regularization_factor is used for the selection of regularization factor, default:"2^-10"
generated_length=200;                     %generated_length is used for the setting of the number of generated frames for DT, default:"200"


functionname='similarity_RGB';
%==============================================
disp(sprintf('%s: reading file %s', functionname, filename))

if( ~exist( ['results/Similarity-RGB/'], 'dir' ) )
        mkdir(['results/Similarity-RGB/']);
end


video=VideoReader(filename);
Nreal=video.NumberOfFrames;
H=video.Height;
W=video.Width;

delete (video);
clear video;
video=VideoReader(filename);
videoName = [savename,'-Similarity'];
aviobj=VideoWriter(fullfile('results/Similarity-RGB/',videoName));
fps = 25;
aviobj.FrameRate=fps;

N=Nreal;
if (N > 200)
    N = 200;
end
f=N;

H1=100;
W1=150;

Y=zeros(f,H1*W1*3);
for k=1:f
    image=double(readFrame(video))./255;
    image=imresize(image,[H1,W1]);
    Y(k,:)=reshape(image,[1,H1*W1*3]);
end
%==============================================
disp(sprintf('%s: video loaded', functionname))
Ymean=mean(Y,1);

Y=Y-ones(N,1)*Ymean;

[OutputWeight] = kernelelm(Y,N,regularization_factor,kernel_type,kernel_coefficient);

imageinitial=Y(1,:)';
P=Y(1:N-1,:)';
%==============================================
disp(sprintf('%s: generating new frames', functionname))
figure;

for i=2:generated_length
    disp(sprintf('frame:%d',i));
    Omega_test = kernel_matrix(P',kernel_type,kernel_coefficient,imageinitial');
    imageinitial=(Omega_test' * OutputWeight)';
    imageinitial1=imageinitial+Ymean';
    imagere=reshape(imageinitial1,[H1,W1,3]);
    imagere(imagere<0)=0;
    imagere(imagere>1)=1;
    
    
    imshow(imagere);
    if (mod(i,200) == 0)
        disp(sprintf('%s: %d frames generated', functionname, i));
    end
    
    %open(aviobj);
    %writeVideo(aviobj,imagere);
    
end
close(aviobj);
clear all;
end
