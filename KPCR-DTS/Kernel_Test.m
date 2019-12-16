function [K_tst]=Kernel_Test(X,Xt,type,par1,par2)

%%% kernel (Gram) matrix computation - testing data 
%%%
%%% Inputs  
%     X -  N  x dim matrix of training input data (number of samples  x dimension)
%     Xt - Nt x dim matrix of testing  input data (number of samples  x dimension)
%                                                      par1    par2 
%     type:  'G' Gaussian   Kernel  exp((|x-y|^2)/w)   w       0 
%            'P' Polynomial Kernel  (<x,y>+c)^a:       a       c     
%
%%  Output 
%     Hs - N x N  kernel matrix  




[N,dim]=size(X);
[Nt,dim]=size(Xt);

K_tst = zeros(Nt,N);
 
if type=='G'  
 for i=1:Nt
   for j=1:N
     K_tst(i,j) = norm(Xt(i,:)-X(j,:))^2 ;
   end
 end
 K_tst=exp(-K_tst/par1);
end

if type=='P'  
 for i=1:Nt
   for j=1:N
     K_tst(i,j)=(dot(Xt(i,:),X(j,:))+par2)^par1;
   end
 end
end 

if type=='L'  
    K_tst=Xt*X'; 
end     

