function [P_X,W,D,Q,K]=KPCA1(X,n_pc,type,par1,par2)

    %%% Kernel Principal Component Analysis
    %%%
    %%% Inputs  
    %     X  : training data points  (number of samples  x dimension)
    %     Xt : testing  data points  (number of samples  x dimension)
    %
    %     n_pc : number of principal componets onto which data are projected 
    %
    %                                                      par1    par2 
    %     type:  'G' Gaussian   Kernel  exp((|x-y|^2)/w)   w       0 
    %            'P' Polynomial Kernel  (<x,y>+c)^a:       a       c     
    %
    %%  Output 
    %     P_X  : projection of training data  onto the first n_pc  principal componets (number of samples  x n_pc)
    %     P_Xt : projection of testing  data  onto the first n_pc  principal componets (number of samples  x n_pc)
    %        
    %     W,D  : eigenvectors and eigenvalues of the centralized (cen_K) training data kernel matrix 
    %          : !!!!  eigenvalues coresponding to the sample covariance matrix are D/(n-1)

   

    
    [n,dim]=size(X);
%     [nt,dim]=size(Xt);

    %%% training data kernel matrix construction  
    K=Kernel(X,type,par1,par2);
    
    %%% centering of K 
    M=eye(n)-ones(n,n)/n;
    cen_K=M*K*M;
    
    %%% KPCA 
    %[W,D,Exp]=pcacov(cen_K);
    %%% this is the pcacov() function from Matlab Statistical Toolbox :
    [u,D,W] = svd(cen_K);
    D = diag(D);
    totalvar = sum(D);
    Exp = 100*D/totalvar;
    clear u 

    
    %% here the eigenvalues and eigenvectors are ordered in decreasing order 
    %%% !!! eigenvalues coresponding to the sample covariance matrix are D/(n-1)

    
    %%% training data projection 
    for k=1:n_pc 
       P_X(:,k)=W(:,k)*sqrt(D(k));
    end 
    
    %%% TESTING PART 
    
%     % testing data kernel matrix construction 
%     Kt=Kernel_Test(X,Xt,type,par1,par2);
%     
%     %%% centering of Kt 
%     Mt=ones(nt,n)/n;
%     cen_Kt = (Kt - Mt*K)*M;
% 
    for k=1:n_pc
       Q(:,k)=W(:,k)/(sqrt(D(k))); 
    end 
%     
%     %%% testing  data projection 
%     P_Xt=cen_Kt*Q;
    
    

    
    
    