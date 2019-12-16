function Hs=Kernel(X,type,par1,par2)

%%% kernel (Gram) matrix computation - training data 
%%%
%%% Inputs  
%     X - N x dim matrix of input data (number of samples  x dimension)
%                                                      par1    par2 
%     type:  'G' Gaussian   Kernel  exp((|x-y|^2)/w)   w       0 
%            'P' Polynomial Kernel  (<x,y>+c)^a:       a       c     
%
%%  Output 
%     Hs - N x N  kernel matrix  


[N,dim]=size(X);
Hs=zeros(N,N);
if type=='G'  
    for i=1:N 
    Hs(i,i)=0;
     for j=i+1:N
       Hs(i,j)=norm(X(i,:)-X(j,:))^2;
       Hs(j,i)=Hs(i,j);
     end 
    end
    Hs=exp(-Hs/par1);
end 
if  type=='P'
   for i=1:N
     for j=i:N
      dp=(dot(X(i,:),X(j,:))+par2)^par1;
      Hs(i,j)=dp;
      Hs(j,i)=Hs(i,j);
     end 
   end 
end

if  type=='L'
   Hs=X*X';
end