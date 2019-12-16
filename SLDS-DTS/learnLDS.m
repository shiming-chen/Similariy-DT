function [Ahat, Chat, Qhat, Rhat, Xhat, Ymean] = learnLDS(Y, n, d, algo)

% LEARNLDS Learns a Linear Dynamical System (LDS) from data using subspace
%          identification.
%
%  Syntax
%  
%    [Ahat, Chat, Qhat, Rhat, Xhat, Ymean] = learnLDS(Y, n, d, algo)
%
%  Description
%
%     Implements algorithms described in
%     ' A Constraint Generation Approach for Learning Stable Linear
%     Dynamical Systems'
%     Sajid M. Siddiqi, Byron Boots, Geoffrey J.Gordon
%     NIPS 2007
%       
%     Given a data sequence and desired model dimension n, the code applies
%     subspace identification techniques to learn model parameters.
%     This involves performing SVD on a Hankel matrix of stacked
%     observations to obtain a state sequence estimate. The size of the
%     Hankel matrix is specified by d. The dynamics matrix is trained using
%     constraint generation. The dynamics matrix can also be learned
%     using simple least squares, which is optimal wrt reconstruction error
%     of the state sequence but may be unstable. Alternatively, it can be
%     learned using previous work in learning stable systems by Lacy and
%     Bernstein, which guarantees stability but is less accurate and
%     efficient.
%      
%
%
%  LEARNLDS(Y, n, d, algo)      
%     takes these inputs:
%       Y       - Matrix of m-dimensional observations. Columns are individual
%                 observations.
%       n       - The model dimension.
%       d       - Number of observations per column in the Hankel Matrix.
%       algo    - Method for learning the dynamics matrix (1-4)
%                1 : constraint generation (enforces stability) default
%                2 : least squares (ignores stability)
%                3 : Lacy-Bernstein 1 (enforces stability)
%                4 : Lacy-Bernstein 1 simulated using constraint generation
%                5 : Lacy-Bernstein 2 (enforces stability)
%
%     and returns:
%       Ahat       - n x n Dynamics Matrix estimate
%       Chat       - m x n Observation Model Matrix estimate
%       Qhat       - n x n Covariance Matrix for state evolution noise
%       Rhat       - m x m Covariance Matrix for observation model noise
%                    (not computed or used for data with m > 100) 
%       Xhat       - Identified Latent State Sequence estimate. X(:,t) = x_t
%       Ymean      - the mean of the observations, which must be added back to
%                    data simulated from the model
%
% Authors: Sajid Siddiqi and Byron Boots
% If you use this code in your research, please cite the above paper.

m   = size(Y,1);
t   = size(Y,2);

% Subtract Mean from Observations
Ymean = mean(Y,2);
Y = Y - Ymean*ones(1,t);

% Build Hankel Matrix
tau = t - d+1;
D = zeros(d*m, tau);

for i = 1:d
    for j = 1:tau
        D((i-1)*m + 1:i*m,j) = Y(:,(j-1) + i);   
    end
end

D = D';
    
% Perform SVD on Hankel Matrix
if size(D,2) < size(D,1)
    [V,S,U] = svd(D,0);
else
    [U,S,V] = svd(D',0);
end

V = V(:,1:n);
S = S(1:n,1:n);
U = U(:,1:n);

Xhat = S*V';
Chat = U(1:m,:);

% Estimate Dynamics Matrix
S1 = Xhat(:,1:end-1);
S2 = Xhat(:,2:end);

switch algo
    case 1    % Constraint Generation
        disp('Learning Dynamics Matrix using Constraint Generation');
        Ahat = learnCGModel(S1,S2,0);
        
    case 2    % Least Squares
        disp('Learning Dynamics Matrix using Least Squares');
        Ahat = S2*pinv(S1);

    case 3    % Lacy Bernstein 1
        disp('Learning Dynamics Matrix using Lacy Bernstein 1');
        Ahat = learnLB1Model(S1,S2);
        
    case 4    % Lacy Bernstein 1 simulated using CG
        disp('Learning Dynamics Matrix using Simulated Lacy Bernstein 1');
        Ahat = learnCGModel(S1,S2,1);
        
    case 5    % Lacy Bernstein 2
        disp('Learning Dynamics Matrix using Lacy Bernstein 2');
        Ahat = learnLB2Model(S1,S2);
        
    otherwise
        disp('invalid algo parameter');
end

% Estimate Evolution and Observation Noise Covariance Matrices
What = S2-Ahat*S1;
Qhat = cov(What');

if m <= 100
    Vhat = Y - Chat*Xhat;
    Rhat = cov(Vhat');
else
    Rhat = [];
end
