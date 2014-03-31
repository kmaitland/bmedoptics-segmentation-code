clc;
clear all;
close all;

% Get Kristen's File
[filename, pathname, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'Image 1');

% Get Program File
[filename2, pathname2, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'Image 2');

% File Number
fn = 8;

I = imcrop(imread([pathname filename]),[1 1 999 999]);
I2 = imcrop(imread([pathname2 filename2]), [1 1 999 999]);

% Get Mask
% Kristen
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);
mask = (g < 90) & (r > 110);
filled_mask = imfill(mask, 'holes');
% Program
r2 = I2(:,:,1);
g2 = I2(:,:,2);
b2 = I2(:,:,3);
mask2 = (g2 < 90) & (r2 > 110);
filled_mask2 = imfill(mask2, 'holes');

% Get FOV mask
FOV_mask = imfill(((b > 110) | (b2 > 110)),'holes');

% Find Overlap
mo = uint8(filled_mask) + uint8(filled_mask2);

% Display Overlap
green = (mo == 2); % Image overlap
blue = filled_mask - green; % Image 1 non-overlap
red = filled_mask2 - green;% Image 2 non-overlap
output = cat(3, red, green, blue);
figure, imshow(output, []);

% Get Area
% Image 1
area1 = zeros(1,max(max(bwlabel(filled_mask))));
R = regionprops(logical(filled_mask),'Area'); % Label Image 1
% Get image without intersections
img1out = bwlabel(filled_mask);
overlap1 = img1out.*(filled_mask & green); % Obtain mask of labelled overlaps
for n=1:max(max(img1out))
    if sum(sum(overlap1 == n)) == 0
        area1(n) = R(n).Area;
    else
        img1out(img1out == n) = 0;
    end
end
area1(area1 == 0) = [];
csvwrite('image1.csv',area1');
num_blue = max(max(bwlabel(img1out)));
img1out = cat(3,img1out,zeros(size(img1out)),zeros(size(img1out)));
imwrite(img1out, 'mask.png', 'png');

% Image 2
area2 = zeros(1,max(max(bwlabel(filled_mask2))));
R = regionprops(logical(filled_mask2),'Area'); % Label Image 2
% Get image without intersections
img2out = bwlabel(filled_mask2);
overlap2 = bwlabel(filled_mask2).*(filled_mask2 & green); % Obtain mask of labelled overlaps
for n=1:max(max(bwlabel(filled_mask2)))
    if sum(sum(overlap2 == n)) == 0
        area2(n) = R(n).Area;
    else
        img2out(img2out == n) = 0;
    end
end
area2(area2 == 0) = [];
csvwrite('image2.csv',area2');
num_red = max(max(bwlabel(img2out)));
img3out = cat(3,filled_mask2-img2out,zeros(size(img2out)),zeros(size(img2out)));
img2out = cat(3,img2out,zeros(size(img2out)),zeros(size(img2out)));
imwrite(img2out, [num2str(fn) '_negative.png'], 'png');
imwrite(img3out, [num2str(fn) '_positive.png'], 'png');

% Area of overlapping objects
area3 = zeros(1,max(max(bwlabel(green))));
R = regionprops(logical(green),'Area'); % Label Overlap image
for n=1:max(max(bwlabel(green)))
        area3(n) = R(n).Area;
end
csvwrite('overlap.csv',area3');


% Count # of overlapping objects
num_green = max(max(bwlabel(green)));

% Display stuff
disp(['# of Overlapping objects (green) = ' num2str(num_green)]);
disp(['# of Non-overlapping image1 objects (red) = ' num2str(num_red)]);
disp(['# of Non-overlapping image2 objects (blue) = ' num2str(num_blue)]);
disp('Total Area (in pixels) of: '); 
disp(['Overlapping objects (green) = ' num2str(sum(area3))]);
disp(['Non-overlapping image1 objects (red) = ' num2str(sum(area2))]);
disp(['Non-overlapping image2 objects (blue) = ' num2str(sum(area1))]);
disp(['Active FOV area = ' num2str(sum(sum(FOV_mask)))]);