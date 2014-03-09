function [filled_mask, img_props] = create_mask(img, oimg, erode, show_fig)
% create_mask
%   Creates mask from hand segmentation

% Get Mask
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
mask = (g < 90) & (b < 90) & (r > 110);
filled_mask = imfill(mask, 'holes');
if erode == 'Y'
    se = strel('disk', 1, 8);
    filled_mask = imerode(filled_mask, se);
end

% Save Area, Eccentricity
img_props = regionprops(bwconncomp(filled_mask), oimg, 'all');

% Show figure
if show_fig == 'Y'
    figure, imshow(filled_mask);
end

% Label Objects
for k = 1:numel(img_props)
    x = img_props(k).Centroid;
    if show_fig == 'Y'
        text(x(1),x(2),sprintf('%d',k),...
            'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle',...
            'Color', [1,0.6,0]);
    end
end