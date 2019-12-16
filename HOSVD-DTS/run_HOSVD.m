function [training_time, generating_time, PSNR_out] = run_HOSVD(filename, savename)

    functionname='HOSVD';
    %==============================================
    disp(sprintf('%s: reading file %s', functionname, filename))
    tic

    % Add path for Tensor Toolbox V1.0
    addpath('HOSVD_DTS/TensorToolbox_V1.0');
    video=VideoReader(filename);
    Nreal=video.NumberOfFrames;
    H=video.Height;
    W=video.Width;
    
    delete (video);
    clear video;
    video=VideoReader(filename);

    N=Nreal;
    if (N > 200)
        N = 200;
    end
    % Setting Parameters 
    texture_name = 1;  % Choose the DT sequence for testing, set as 1,2,3,4
    tau = N; % Length of the training samples
    r3 = 40; % The dimension of the subspace for the space domain 
    r1 = 200; % The dimension of the subspace for the time domain 

    H=100;H1=100;
    W=150;W1=150;
    

    im =readFrame(video);
    im=imresize(im,[H1,W1]);

    [a b c] = size(im); % Get the size of the frame
    
    video=VideoReader(filename);

    % Save the DT sequence data as a tensor
    Y = zeros(a,b,tau,c);
    Y1=zeros(a*b,tau);
    for i = 1:tau  
        temp = double(readFrame(video));  
        temp=imresize(temp,[H1,W1]);

        temp=temp./255;
        temp1=rgb2gray(temp);
        Y1(:,i)=temp1(:);
        Y(:,:,i,1) = temp(:,:,1);
        Y(:,:,i,2) = temp(:,:,2);
        Y(:,:,i,3) = temp(:,:,3);
    end
    %==============================================
    disp(sprintf('%s: video loaded', functionname))
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


    training_time=toc;

    %video=VideoReader(filename);
    %origimage=readFrame(video);
    %PSNR=[];

    %==============================================
    disp(sprintf('%s: generating new frames', functionname))
    tic

    % Synthesis the DT video based on 1st Order Markov Model and Linear Dynamic
    % Model. 
    S = ttm(Yt,{U',V',F',W'});  
    syn_length = Nreal; % 1500 frames are synthesized.

    % Generate new frames using the last frame of training sample as the
    % initial frame
    X(:,1) = Xhat(:,1);
    
    % Calculate the dynamic trajectory of the DT sequence in the subspace
    for t = 1:Nreal
    % X(:,t+1) = Ahat*X(:,t) + Bhat*randn(nv,1);
        X(:,t+1) = Ahat*X(:,t);
    end      

    F = X'; 

    B = tucker_tensor(S,{U,V,F,W});
    core = tensor(B.lambda);
    Yp = ttm(core, {U,V,F,W});
    YpM1 = tensor_as_matrix(Yp,3);

    for k=2:Nreal
        imm_pred = reshape(YpM1(k,:),a,b,c);
        frame=rgb2gray(imm_pred);
        frame(frame<0)=0;
        frame(frame>1)=1;

        %origimage=double(rgb2gray(readFrame(video)))./255;
        %origimage=imresize(origimage,[H1,W1]);

        %PSNR=[PSNR, psnr(origimage, frame)];
        
        if (mod(k,200) == 0)
            disp(sprintf('%s: %d frames generated', functionname, k));
        end
        imwrite (frame, sprintf('images/%s/%s-%d.png', savename, functionname, k));
    end
    generating_time=toc;
    PSNR_out=0;%mean(PSNR);
end
