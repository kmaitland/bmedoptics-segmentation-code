function [output, bg_area, mask] = bg_remove(input)
% Background Remover
%   Removes Background from Image

%disp('#REMOVING BACKGROUND')
%set(lb, 'String', cmdwinout());

% [w l] = size(input);

% Create Binary Mask
binary_mask = ~im2bw(input, graythresh(input)/1.5);
% figure, imshow(binary_mask);

% Find Large Areas
properties=regionprops(binary_mask, 'Area');
idx = ([properties.Area] > 10000);
L = labelmatrix(bwconncomp(binary_mask));
mask = ismember(L, find(idx));
h_mask = imfill(mask, 'holes');
holes = h_mask & ~mask;
bigholes = bwareaopen(holes, 1000);
smallholes = holes & ~bigholes;
mask = mask|smallholes;
% figure, imshow(mask), title('Mask');

% Set Selected Region to 0
input(mask == 1) = 0;

% Setup Outputs
output = input;
mask = imcomplement(mask);
% figure, imshow(output), title('Output');

% Calculate 'Real Image Area'
bordered_mask = bwperim(mask); % For consistency
mask = imfill(bordered_mask,'holes'); % For consistency
bg_area = nnz(mask);
end