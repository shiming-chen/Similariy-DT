function [training_time, generating_time, PSNR_out] = run_FFTLDS(filename, savename)

    functionname='FFTLDS';

    %==============================================
    disp(sprintf('%s: reading file %s', functionname, filename))
    tic
    
    video=VideoReader(filename);
    Nreal=video.NumberOfFrames;
    H=video.Height;
    W=video.Width;
    
    delete (video);
    clear video;
    video=VideoReader(filename);
    H=100;H1=100;
    W=150;W1=150;
    
    N=Nreal;
    if (N > 200)
        N = 200;
    end

    f=N;
    Y=zeros(f,H*W);
    % Setting Parameters 
    Thr = 90; 
    %% 
    n_fft_rgb_vec =50;
    tau = N;  % The length of training sequence


    im =read(video,1);
    im=imresize(im,[H1,W1]);
    video=VideoReader(filename);


    [a b c] = size(im); % Get the size of the frame
    Y1=zeros(a*b,tau);
    for i = 1:tau
        temp = double(rgb2gray(readFrame(video))); 
        temp=imresize(temp,[H1,W1]);
        
        temp=temp./255;
        Y1(:,i)=temp(:);
        fft_temp_gray = fft2(temp);    
        %% 
        Y_fft(:,:,i) = fft_temp_gray(:);
        Y_gray(:,i) = temp(:);
    end
    %==============================================
    disp(sprintf('%s: video loaded', functionname))
    
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

    %video=VideoReader(filename);
    %PSNR=[];
    training_time=toc;
    %==============================================
    tic
    disp(sprintf('%s: generating new frames', functionname))
    for t=1:Nreal
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
        % synth_Result(t).frame = Y_synth_gray;

        %origimage=double(rgb2gray(readFrame(video)))./255;
        %origimage=imresize(origimage,[H1,W1]);

        %PSNR=[PSNR, psnr(origimage, Y_synth_gray)];

        if (mod(t,200) == 0)
            disp(sprintf('%s: %d frames generated', functionname, t));
        end
        imwrite (Y_synth_gray, sprintf('images/%s/%s-%d.png', savename, functionname, t));
        

    end
    generating_time=toc;
    PSNR_out=0;%mean(PSNR);
end
