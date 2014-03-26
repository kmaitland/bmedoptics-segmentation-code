function [segmented, img_props] = GMRF_seg(I, GMRF_levels, max_size,...
    min_size, eccen, solidity, pathname, filename)

% Convert I to double
I = double(I);

% GMRF - Runs GMRF segmentation process
S = anisodiff_med(I, 50, 25, .5,3,1,3);
% figure, imshow(S);

I_double = S;
levels = linspace(0,max(I_double(:)), GMRF_levels);
GMRF_frame = GMRF(I_double', 0.00001, levels)';
% figure, imshow(GMRF_frame);

size_filter = choose_nuclei(GMRF_frame, max_size, min_size);
% figure, imshow(size_filter);

L = bwlabel(size_filter);
B=regionprops(L,'Eccentricity');
objects = ([B.Eccentricity] < eccen);
efilter = ismember(L, find(objects));
% figure, imshow(efilter);

L = bwlabel(efilter);
B=regionprops(L,'Solidity');
objects = ([B.Solidity] > solidity);
Y = double(ismember(L, find(objects)));
% figure, imshow(Y);

% Get object properties
L = bwlabel(Y);
B = regionprops(L, I, 'All');
B2 = bg_finder(Y, I, B);
object_props = [(0.5625*[B.Area])', [B.Eccentricity]', [B.Extent]',...
    [B.Solidity]', ([B.MeanIntensity])',...
    ((([B.MaxIntensity]-[B.MinIntensity])/4))',...
    ([B2.MeanIntensity])',...
    ((([B2.MaxIntensity]-[B2.MinIntensity])/4))'];

% Apply Neural Network
load('GMRFnet'); % Import pretrained network
classified = net(object_props');
output = zeros(size(L));
for i=1:length(classified)
    if (classified(i) >= 0.5)
        disp(classified(i));
        output = double(L == i) + output;
    end
end

L = bwlabel(output);
img_props = regionprops(L, 'all');

% Convert I back to uint8
I = uint8(I);

BWoutline = bwperim(output);
Segout_R = I; Segout_R(BWoutline) = 255;
Segout_G = I; Segout_G(BWoutline) = 0;
Segout_B = I; Segout_B(BWoutline) = 0;
segmented = cat(3, Segout_R, Segout_G, Segout_B);
% figure, imshow(segmented);
imwrite(segmented, [pathname strtok(filename,'.') '_seg.png'], 'png');