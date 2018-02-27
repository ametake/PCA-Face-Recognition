function [ Accuracy ] = SRBFR(numTrainee, path)
%SRBFR Summary of this function goes here
%   Detailed explanation goes here

%	The procession contains:
%	1.read the training set
%	2.construct matrix and transpose to X
%	--------------call PCA---------------
%	3.find the covariance matrix and its eigen
%	4.got the p eigvecs COEFF and eigvs LATENT decending
%	--------------PCA ends---------------
%	5.take k eigenvectors with 95% propeeertion as E
%	6.project training matrix and test matrix on E
%   7.calculate the accuracy

%	1.read the training set

% return the path of the folder and its sons, divided by ':'colon
p = genpath(path);
len = size(p,2);
p = deblank(p);

% save the path of the folders, notice that in the folders are cell but not string
folders = regexp(p,pathsep,'split');

% read pictures from all folder
% file_num is the number of folders
file_num = size(folders,2) - 1;

% S is a cell with file_num matrix
S = cell([1, file_num]);
disp('read pictures from all folder...');
for i = 2:file_num
    fprintf('reading the %d th \n',i-1);
	% set of this folder
    % P is p*n with n pictures as columns
	P = [];
    file_path =  char(folders{i});
    file_path = strcat(file_path,'/');

    % read pictures in the ith folder
    img_path_list = dir(strcat(file_path,'*.pgm'));
    img_num = length(img_path_list);
    if img_num > 0

    	% minus all pictures with Ambient
    	amb = [];
        for j = 1:img_num
            image_name = img_path_list(j).name;
            image =  im2double(imread(strcat(file_path,image_name)));
            image = imresize(image, 0.9);
            % save the ambient
            if ~isempty(strfind(image_name, 'Ambient'))
            	amb = image;
            else
                [pr, pc] = size(image);
            	vec = reshape(image, pr*pc, 1);
            	P = [P vec];
            end
        end
        vec = reshape(imresize(amb, [pr, pc]), pr*pc, 1);
        
        P = P - repmat(vec, 1, img_num-1);
        
        % make P be in ramdom colomn order
        r = randperm(size(P,2));
        P = P(:, r);
        S{i} = P;
        p = pr*pc;
    end
end

%	2.construct matrix and transpose to X

%   NOTE:
%   This is a script that divide the dataset into two part for train and test

% seperate training set from every folder
train_set = [];

% the test set size for this folder and for all pictures
% notice that in each folder, numTest is different, recorded in numTest(i)
test_set = [];
numTest = [0];
totTest = 0;


for i = 2:file_num
    train_set = double([train_set S{i}(:,1:numTrainee)]);
    numTest = [numTest size(S{i},2) - numTrainee];
    totTest = totTest + size(S{i},2) - numTrainee;
    test_set = double([test_set S{i}(:,numTrainee + 1:size(S{i},2))]);
end

%   now all 3 set are p*m matrix, m is the number of pictures in it
%   3&4.using PCA
%   using n*p train_set', got p eigvecs COEFF in columns  and eigvs LATENT decending

[coeff, score, latent] = PCA(train_set');

%   5.take k eigenvectors with 95% propeeertion as E

l = 0;
for k = 1:p
    l = l + latent(k);
    if l/sum(latent) >= 0.95
        break;
    end
end
coeff = coeff(:,1:k);
%csvwrite('coeff.csv',coeff);

%   6.project training matrix and test matrix on E
% fprintf('%d %d %d %d %d\n',size(train_set,1),size(train_set, 2),size(mean(train_set, 2), 1),size(mean(train_set, 2), 2),numTrainee*(file_num - 1));
train_set = train_set - double(repmat(mean(train_set, 2), 1, numTrainee*(file_num - 1)));
test_set = test_set - double(repmat(mean(test_set, 2), 1, totTest));

train_proj = double(coeff'*train_set);

test_proj = double(coeff'*test_set);


%   7.calculate the accuracy

lambda = 1.75;
init_x = zeros(numTrainee*(file_num - 1),1);

right = 0;
% for every column(y, picture) in new set
for i = 1:totTest
    x = feature_sign(train_proj,test_proj(:,i),lambda,init_x);
    t = 0;
    pic = 0;
    % for every pic in train set, sum their contributions and find the maximum
    for j = 0:(file_num - 2)
        if sum(x(numTrainee*j+1:numTrainee*(j+1))) > t
            t = sum(x(numTrainee*j+1:numTrainee*(j+1)));
            pic = j + 1;
        end
    end
    % check if the guess is right
    t = i;
    for j = 2:file_num
        if t - numTest(j) > 0
            t = t - numTest(j);
        else
            break;
        end
    end

    if j - 1 == pic
        right = right + 1;
    end
end

Accuracy = right/totTest;

end