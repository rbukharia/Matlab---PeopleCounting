clear
clc
close all
tic
%% ------ open data test from directory ----------
H=[];
%load hard3.mat
%load hardtrain.mat
%--inisialisasi positif files-----------------------------
jpg_lists1 =dir(fullfile('data_pos/inria','*.png'));
dir_pos =size(jpg_lists1,1);

%--inisialisasi negatif files-----------------------------
jpg_lists2 =dir(fullfile('data_neg/inria','*.png'));
jpg_lists3 =dir(fullfile('data_neg/inria','*.jpg'));
jpg_lists4 =[jpg_lists2;jpg_lists3];
dir_neg =size(jpg_lists4,1);

%% --training positif files-----------------------------
for i=1:dir_pos 
  disp(['data positif ke ', num2str(i)]);
  rgb=imread(['data_pos/inria/' jpg_lists1(i).name]);
  img = rgb2gray(rgb);
  im = imcrop(img,[16 16 63 127]);
  H =[H;[permute(HoG(double(im)),[2,1]) 1]];
end
% save ('feature_pos5.mat','H');
% clear H
% clc
% close all
% H=[];
%% --training negatif files-----------------------------
for i=1:dir_neg
  disp(['data negatif ke ', num2str(i)]);
  rgb=imread(['data_neg/inria/' jpg_lists4(i).name]);
  img = rgb2gray(rgb);
  for j=1:2
  x = randi(size(img,1)-128,1,1);
  y = randi(size(img,2)-64,1,1);
  im = imcrop(img,[y x 63 127]);
  H =[H;[permute(HoG(double(im)),[2,1]) -1]];
  end
end
% save 'feature_neg6.mat' 'H';
% H2=H;
% load feature_pos5.mat
% H=[H;H2];
% clear H2
% save 'final6.mat' 'H';
%% hard training
%H =[H; hard];

%H2=[];
%for i=1:453
%    hard=[];
%    if mod(i,100)==0 || i==1217
%        load (['hardtrain',num2str(i),'.mat'])
%        H2=[H2;hard];
%    end
%end
%% -- persiapan data training ---
data_train=H(:,1:size(H,2)-1);
% 
% %--- label atau group masing-masing row data ---
% %--- terdapat pada kolom pertama
label_train=H(:,size(H,2));
% 
clear H
% %--- training data svm ---------------
% 
% SMO_OptsStruct = svmsmoset('MaxIter', 1000000);
% svm_struct_all = svmtrain(data_train, label_train, 'Method', 'SMO', 'Options', SMO_OptsStruct);
model = svmperflearn(data_train, label_train, '-c 20.0');
% %svm_struct_all = svmtrain(data_train, label_train, 'Kernel_Function', 'rbf','Method', 'QP');
% 
% save 'final2.mat' 'H';
save 'svmstruct_all7' model;

toc