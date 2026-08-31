function [B, df] = ridgesvd_with_df(Y,X,lambda)

% Y       Tx1
% X       TxP
% lambda  Lx1
% B       PxL
% df      Lx1

% % Uncomment to check code
% T       = 100;
% P       = 1000;
% X       = randn(T,P);
% Y       = randn(T,1);
% lambda  = 1;

% Y = Ytrn';
% X = Ztrn';
% lambda = lamlist/trnwin;

% Ytrn',Ztrn',lamlist
if sum(isnan(X(:)))+sum(isnan(Y))>0
    error('missing data')
end

L       = length(lambda);
[U,D,V] = svd(X); 
%D       = diag(D); % NB - moved below
[T,P]   = size(X);

% NB: Addition for T=1 case
if T == 1
    D       = D(1); % (as it is 1 x P)
else
    D       = diag(D); 
end

if T>=P
    compl   = zeros(P,T-P);
else
    compl   = zeros(P-T,T);
end

% Pre-allocate outputs
B       = nan(P,L);
df      = nan(L,1);

for l=1:L
    % Compute ridge regression coefficients
    if T>=P
        B(:,l)      = V*[diag(D./(D.^2+lambda(l))),compl]*U'*Y;
    else
        B(:,l)      = V*[diag(D./(D.^2+lambda(l)));compl]*U'*Y;
    end

    % Compute effective degrees of freedom using already computed singular values D
    df(l) = sum((D.^2) ./ (D.^2 + lambda(l)));
    
end

% % Uncomment to check code
% scatter45line(B(:,1),(X'*X+lambda(1)*eye(P))\X'*Y)

