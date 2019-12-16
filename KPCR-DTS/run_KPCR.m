function [training_time, generating_time, PSNR_out] = run_KPCR(filename, savename)

    functionname='KPCR';
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
    H1=H;
    W1=W;

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

    Mt=ones(1,n)/n;
    training_time=toc;
    %video=VideoReader(filename);
    %origimage=readFrame(video);
    %PSNR=[];
    %==============================================
    disp(sprintf('%s: generating new frames', functionname))
    tic
    for num=2:Nreal
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

        %origimage=double(rgb2gray(readFrame(video)))./255;
        %origimage=imresize(origimage,[H1,W1]);

        %PSNR=[PSNR, psnr(origimage, newimage)];

        if (mod(num,200) == 0)
            disp(sprintf('%s: %d frames generated', functionname, num));
        end
        imwrite (newimage, sprintf('images/%s/%s-%d.png', savename, functionname, num));
    end
    generating_time=toc;
    PSNR_out=0;%mean(PSNR);
end
