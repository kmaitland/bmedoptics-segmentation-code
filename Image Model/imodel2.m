clc;
clear all;
close all;

% Parameters
bg = 50;
noisefg = (41/255)^2; % Variance; foreground
noisebg = (35/255)^2; % Variance; background

filename_num = '250';

% Turn on red border
rb = 'off';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gaussian
G = @(img,x,y,i,j) double(img(x,y))*(1/(2*pi*s^2))*...
    exp(-((x-i)^2+(y-j)^2)/(2*s^2));

% Create Background
I = bg*ones(1000,1000)/255;

% Read in Image
obj = double(imread(['image_model' filename_num '.png']))/255;/

% Separate bg from objects
obj_mask = obj > (bg/255);
% figure, imshow(obj_mask);

% Apply noise to bg and objects separately
obj = imnoise(obj,'gaussian',0,noisefg);
I = imnoise(I,'gaussian',0,noisebg);
% figure, imshow(obj,[]);
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
end
    
% Display Images
% figure, imshow(uint8(I*255));

% Write image to disk
imwrite(I,['image_model' filename_num '_' num2str(bg)  '.png'],'png');