clc;
clear all;
close all;

% Parameters
bg = 50; % Average Background Intensity
noisefg = (3.97)^2; % Variance; foreground
noisebg = (35/255)^2; % Variance; background

filename_num = 'test'; % Filename to Save

% Turn on red border (on/off)
rb = 'off';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create Background
I = bg*ones(1000,1000)/255;

% Read in Image
% obj = double(imread(['image_model' filename_num '.png']))/255;
load('imagemodel.mat');
obj = double(obj);

% Obtain Centroid for each object
R = regionprops(logical((obj > 0)),'Centroid');
% Let Center_mask be the same size as output
Center_mask = zeros(size(obj));
% Plot on mask
for i = 1:length(R)
    column = floor(R(i).Centroid(1,1));
    row =  floor(R(i).Centroid(1,2));
    Center_mask(row,column) = 1;
end

% Recreate Intensity Values in Center mask
Center_mask = Center_mask.*obj;

% Gaussian Distribution
Ig = ones(51,51);
s = sqrt(noisefg); 
G = @(img,x,y,i,j) double(exp(-((x-i)^2+(y-j)^2)/(2*s^2)));
for n = 1:51
    for m = 1:51
        Ig(n,m) = G(Ig,26,26,n,m);
    end
end

% Normalization Function
normalize = @(A) (A - min(A(:)))/(max(A(:)) - min(A(:)));

% Normalize
Ig = normalize(Ig);

% Convolute Gaussian on Center Mask; Limit objects to mask size
obj = double((obj > 0).*conv2(Center_mask,Ig,'same'));
% figure, imshow(obj);

% Separate bg from objects
obj_mask = obj > 0;
% figure, imshow(obj_mask);

% Apply noise to bg separately
I = imnoise(I,'gaussian',0,noisebg)*255;
% figure, imshow(I,[]);

% Recombine bg and objects
I = I.*(~obj_mask)+obj.*(obj_mask);

% Red Border on objects
if strcmp(rb,'on')
    BWoutline = bwperim(obj_mask);
    Segout_R = I; Segout_R(BWoutline) = 255;
    Segout_G = I; Segout_G(BWoutline) = 0;
    Segout_B = I; Segout_B(BWoutline) = 0;
    I = cat(3, Segout_R, Segout_G, Segout_B);
else
    % Convert to rgb
    I = cat(3,I,I,I);
end
    
% Display Images
figure, imshow(uint16(I*255),[]);

% Write image to disk
imwrite(uint16(I),['image_model' filename_num '_' num2str(bg)  '.png'],'png');