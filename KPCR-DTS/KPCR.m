function filename = KPCR(filename, savename)
    functionname='KPCR';
    
    video=VideoReader(filename);
    N=video.NumberOfFrames;
    H=video.Height;
    W=video.Width;
    H1=H; W1=W;
    video=VideoReader(filename);
    if (N > 200)
        N = 200;
    end
    f=N;

    Y=zeros(f,H*W);

    for k=1:f
        image=rgb2gray(readFrame(video));
        image=imresize(image,[H,W]);
        Y(k,:)=reshape(image,[1,H*W]);
    end
    Y=Y./255;
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
    for num=2:1200
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
        if (mod(num,200) == 0)
            imwrite (newimage, sprintf('%s-%s-%d.jpg', functionname, savename, num));
        end
    end

    end
end