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

% Get size of image
[w,l] = size(I);

% Gaussian Mask
s = 0.5; 
G = @(img,x,y,i,j) double(img(x,y))*(1/(2*pi*s^2))*...
    exp(-((x-i)^2+(y-j)^2)/(2*s^2));

% Create empty matrix to store filtered image
Ig = zeros(w,l);

% Zero-pad matrix
Ia = padarray(I, [2 2]);
Ig = padarray(Ig, [2 2]);

% Gaussian filter 5x5 mask
for n = 3:(w+2)
    for m = 3:(l+2)
        Ig(n,m) = (G(Ia,n-2,m-2,n,m) + G(Ia,n-1,m-2,n,m) +...
            G(Ia,n,m-2,n,m) + G(Ia,n+1,m-2,n,m) + G(Ia,n+2,m-2,n,m) +...
            G(Ia,n-2,m-1,n,m) + G(Ia,n-1,m-1,n,m) + G(Ia,n,m-1,n,m) +...
            G(Ia,n+1,m-1,n,m) + G(Ia,n+2,m-1,n,m) + G(Ia,n-2,m,n,m) +...
            G(Ia,n-1,m,n,m) + G(Ia,n,m,n,m) + G(Ia,n+1,m,n,m) +...
            G(Ia,n+2,m,n,m) + G(Ia,n-2,m+1,n,m) + G(Ia,n-1,m+1,n,m) +...
            G(Ia,n,m+1,n,m) + G(Ia,n+1,m+1,n,m) + G(Ia,n+2,m+1,n,m) +...
            G(Ia,n-2,m+2,n,m) + G(Ia,n-1,m+2,n,m) + G(Ia,n,m+2,n,m) +...
            G(Ia,n+1,m+2,n,m) + G(Ia,n+2,m+2,n,m));
    end
end

% Remove Padding
Ig = Ig(3:(w+2),3:(l+2));

% Normalization Function
normalize = @(A) (A - min(A(:)))/(max(A(:)) - min(A(:)));

% Normalize
Ig = uint8(255*normalize(Ig));

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