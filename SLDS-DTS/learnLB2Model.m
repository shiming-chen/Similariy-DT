function M = learnLB2Model(S1,S2)
% Implements algorithm in
% Seth L. Lacy and Dennis S. Bernstein. Subspace Identification with
% Guaranteed Stability using Constrained Optimization. IEEE Transactions on
% Automatic Control, 48(7):1259-1263, July 2003
%
% 
% CVX (with Sedumi), publicly available
%   optimization software, is used to solve the optimization problem
%
% Authors: Sajid Siddiqi and Byron Boots

n = size(S1,1);
L = size(S1,2);
r1 = n;
s = n;
delta = .001;
lambda = 0;

U = zeros(size(S1));

tmp1 = [S1 ; U];
term2 = tmp1'*pinv(tmp1*tmp1');
term1 = S2;
term3 = term1*term2;

X1 = term3(1:n,1:n);
B = term3(1:n,n+1:end);

t1 = zeros(r1*s,1);
t2 = -eye(r1*s);
t3 = kron( [zeros(r1,n) eye(n)],[-eye(n) eye(n)*X1] );

t4 = zeros(n*n,1);
t5 = zeros(n*n,r1*s);
t6 = kron([zeros(n) eye(n)],[zeros(n) eye(n)]) - kron([eye(n) zeros(n)],[eye(n) zeros(n)]);
Ax = [t1 t2 t3   ; ...
      t4 t5 t6];
  
bx = delta*[zeros(r1*s,1) ; reshape(eye(n), numel(eye(n)), 1)];

N = 4*n*n + r1*s + 1;

z1_inds = 1;
z2_inds = (1+1):(s*r1 + 1);
z3_inds = (s*r1+1 + 1): (s*r1+1 + 4*n*n);
tmp = reshape((s*r1+1 + 1):(s*r1+1 + 4*n*n),2*n,2*n);
z3_P_inds = tmp(n+1:2*n,n+1:2*n);
z3_P_diag_inds = diag(tmp(n+1:2*n,n+1:2*n));

cx = zeros(N,1);
cx(1) = 1;
cx(z3_P_diag_inds) = lambda;

cvx_begin

  variable z(N)
  minimize (cx'*z)
  subject to
     
     Ax*z == bx;
     z(z1_inds) >= norm(z(z2_inds));
     reshape(z(z3_inds),2*n,2*n) == semidefinite(2*n);
     
cvx_end

Z3 = reshape(z(z3_inds),2*n,2*n);

P = Z3(n+1:2*n,n+1:2*n);
Q = Z3(1:n,n+1:2*n);
Ahat = Q*inv(P);

M = Ahat;

