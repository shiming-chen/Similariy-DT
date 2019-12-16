function [training_time, generating_time, PSNR_out] = run_KDT(filename, savename)
    functionname='KDT';
    %==============================================
    disp(sprintf('%s: reading file %s', functionname, filename))
    tic
    
    video=VideoReader(filename);
    Nreal=video.NumberOfFrames;
    H=video.Height;
    W=video.Width;
    H1=H; W1=W;

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
    for k=1:f
        image=double(rgb2gray(readFrame(video)))./255;  
        image=imresize(image,[H,W]);
        Y(k,:)=reshape(image,[1,H*W]);
    end
    %==============================================
    disp(sprintf('%s: video loaded', functionname))
    Ym=mean(Y,1);
    Y=Y-repmat(Ym,[N,1]);
    
    n=50;
    [X, eigVector, eigValue]=kPCA(Y,n,'gaussian',7);
    T=(X(1:N-1,:)'*X(1:N-1,:))\X(1:N-1,:)'*X(2:N,:);
    Vhat=X(2:N,:)-X(1:N-1,:)*T;
    Vhat=Vhat';
    [Uv,Sv,Vv]=svd(Vhat,0);
    X0=X(1,:);
    Xnew=[];
    
    %newobj=VideoWriter('6kdt3.avi');
    %open(newobj);  

    % tic;
    training_time=toc;
    %video=VideoReader(filename);
    %origimage=readFrame(video);
    %PSNR=[];
    %==============================================
    tic
    disp(sprintf('%s: generating new frames', functionname))
    for t=2:Nreal
        X0=X0*T;
        Xnew=[Xnew;X0];
        normmin=norm(X0-X(1,:));
        xmin=1;
        for j=2:N
            norm1=norm(X0-X(j,:));
            if norm1<=normmin
                normmin=norm1;
                xmin=j;
            end
        end
        Yimage=kPCA_PreImage(X0,eigVector,Y,7,Y(xmin,:)');
        Yimage=Yimage+Ym';
        Yimage(Yimage<0)=0;
        Yimage(Yimage>1)=1;
        newimage=reshape(Yimage,[H1,W1]);

        %origimage=double(rgb2gray(readFrame(video)))./255;
        %origimage=imresize(origimage,[H1,W1]);

        %PSNR=[PSNR, psnr(origimage, newimage)];
       
        if (mod(t,200) == 0)
            disp(sprintf('%s: %d frames generated', functionname, t));
        end
        imwrite (newimage, sprintf('images/%s/%s-%d.png', savename, functionname, t));

    end
    %close(newobj);

    % t=toc
    generating_time=toc; 
    PSNR_out=0;%mean(PSNR);

end
