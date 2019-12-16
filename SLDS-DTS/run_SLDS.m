function [training_time, generating_time, PSNR_out] = run_SLDS(filename, savename)

    functionname='SLDS';
    %==============================================
    disp(sprintf('%s: reading file %s', functionname, filename))
    tic

    n = 50;
    d = 1;
    algo = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Import avi
    
    video=VideoReader(filename);
    Nreal=video.NumberOfFrames;
    H=video.H;
    W=video.W;
    
    delete (video);
    clear video;
    video=VideoReader(filename);
    
    num=Nreal;
    if (num > 200)
        num = 200;
    end

    H=100;H1=100;
    W=150;W1=150;

    % mov = read(mov);
    Y=zeros(H*W,num);
    for i=1:num
        image=double(rgb2gray(readFrame(video)))./255;  
        image=imresize(image,[H,W]);
   
        Y(:,i)=reshape(image,[H*W,1]);
    end
    %==============================================
    disp(sprintf('%s: video loaded', functionname))


    % Learn a Linear Dynamical System (LDS) from Data
    [Ahat, Chat, Qhat, Rhat, Xhat, Ymean] = learnLDS(Y, n, d, algo);


    % Simulate a Video from LDS
    % aviobj = avifile(outputFile,'fps',framesPerSec,'compression','none');


    X = zeros(size(Xhat,1), 1200);
    X(:,1) = Xhat(:,1);
    error=0;

    training_time=toc;

    %video=VideoReader(filename);
    %origimage=readFrame(video);
    %PSNR=[];

    % graylong = [(0:255)' (0:255)' (0:255)']/255;
    %==============================================
    tic
    disp(sprintf('%s: generating new frames', functionname))
    for frameIndex =2:Nreal
    %     X(:,frameIndex+1) = Ahat*X(:,frameIndex) + mvnrnd(zeros(1,n), Qhat)';
        X(:,frameIndex+1) = Ahat*X(:,frameIndex);
        I=Chat*X(:,(frameIndex+1))+Ymean;

        I(I<0)=0;
        I(I>1)=1;
        f = reshape(I,[H, W]);

        %origimage=double(rgb2gray(readFrame(video)))./255;
        %origimage=imresize(origimage,[H1,W1]);

        %PSNR=[PSNR, psnr(origimage, f)];

        if (mod(frameIndex,200) == 0)
            disp(sprintf('%s: %d frames generated', functionname, frameIndex));
        end
        imwrite (f, sprintf('images/%s/%s-%d.png', savename, functionname, frameIndex));
    end
    generating_time=toc;
    PSNR_out=0;%mean(PSNR);
end
