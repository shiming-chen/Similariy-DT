function [training_time, generating_time, PSNR_out] = run_LDS(filename, savename)
    functionname='LDS';
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

    N=Nreal;
    if (N > 200)
        N = 200;
    end
    f=N;

    H=100;H1=100;
    W=150;W1=150;

    Y=zeros(f,H*W);
    wuchaall=[];
    for k=1:f
        image=double(rgb2gray(readFrame(video)))./255;  
        image=imresize(image,[H,W]);
        Y(k,:)=reshape(image,[1,H*W]);
    end
    %==============================================
    disp(sprintf('%s: video loaded', functionname))
    Y=Y';
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

        training_time=toc;
        %video=VideoReader(filename);
        %origimage=readFrame(video);
        %PSNR=[];
    %==============================================
        tic
        disp(sprintf('%s: generating new frames', functionname))
        for t=2:Nreal
            X(:,t)=Ahat*X(:,t-1);
            I(:,t)=Chat*X(:,t)+Ymean;
            newimage=(reshape(I(:,t),[H,W]));
            newimage(newimage<0)=0;
            newimage(newimage>1)=1;

            %origimage=double(rgb2gray(readFrame(video)))./255;
            %origimage=imresize(origimage,[H1,W1]);

            %PSNR=[PSNR, psnr(origimage, newimage)];

            if (mod(t,200) == 0)
                disp(sprintf('%s: %d frames generated', functionname, t));
            end
            imwrite (newimage, sprintf('images/%s/%s-%d.png', savename, functionname, t));
        end

    end
    generating_time=toc;
    %PSNR_out=mean(PSNR);
    PSNR_out=0;
end
