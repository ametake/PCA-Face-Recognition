function [ COEFF, SCORE, LATENT ] = PCA( X )
%PCA Summary of this function goes here
%   Detailed explanation goes here

%	Each row of X is a picture.

%	centralize

[n, ~] = size(X); % n pic each with p pixel
fprintf('size found\n');
x_mean = mean(X, 1);
fprintf('x_mean found\n');
X_mean = repmat(x_mean, n, 1); % n pic each is x_mean, n*p
fprintf('X_mean found\n');
X = X - X_mean;
fprintf('centralized\n');
% X is p*n
C = X'*X;
fprintf('covariance found\n');
% C is p*p
[V,D] = eig(C);
fprintf('eigen found\n');
% V is eigvecs and C is the diagonal eigvs 
% in ascending order, corresponded respectively
% V is p*p and so is D
V = fliplr(V);
% V is p*p
D = rot90(D,2);
fprintf('ordered\n');
COEFF = V;
SCORE = X*V;
LATENT = diag(D);
end