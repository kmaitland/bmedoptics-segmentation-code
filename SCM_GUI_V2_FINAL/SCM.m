function [output, I] = SCM(I, width, height, max_area, min_area,...
    eccen_limit, ap_min, bg_kill, d_mask, cut_mask, lb)

% Created by: Andrew Van (2012)

% Double pass the SCM Filter
S = double(SCM_filter(SCM_filter(SCM_filter(I))));
imwrite(S,'SCM_filter.png','png');

% Apply SCM to get Time Matrix 
S = medfilt2(S); % Median Filter

% Step 1 - Initialize Parameters
T = zeros(width, height);
U = zeros(width, height);
E = zeros(width, height);
Y = zeros(width, height);
alpha_f = 0.075; % alpha_f
f = exp(-alpha_f); % exp(-alpha_f)
b = 0.025; % Beta
W = b*[0.5 1 0.5; 1 0 1; 0.5 1 0.5]; % Weight Matrix, W_ijkl
V_E = 1.4; % V_E
g = exp(alpha_f); % alpha_e; exp(-alpha_e)
num = 6;

% Step 2 - Run SCM
for n = 1:num
    disp(['#Iteration: ' num2str(n)]);
            
    % Internal Activation State
    U = f*U + S.*conv2(Y,W,'same') + S;

    % Neuron Output
    Y = double(U > E);
    
    % Dynamic Threshold
    E = g*E + V_E*Y;
    
    % Record the first time the neuron pulsed; exclude first pulse
    if n ~= 1
        T = T + n.*double(T == 0).*Y;
    end
    
    % figure, imshow(Y);
    % imwrite(Y, [num2str(n) '_a.png'], 'png');
end

% Write Time Matrix
imwrite(T./max(T(:)), 'TimeMatrix.png', 'png');

% Erase pixels that with no values in the time matrix
S = (~(T == 0)).*S;
I_F = S; % Store filtered image
% imwrite(I_F, 'I_F.png', 'png');

% Search Time Matrix and Find Possible Nuclei
N = max(T(:)); % Store Max value of Time Matrix
T_c = N - T; % Get Complement
T_c(T_c == N) = 0; % Set White Pixels to black
S = imregionalmax(T_c); % Create matrix S containing the regional max of T
TM = T; % Create copy of T
TM(S == 1) = 0; % Let TM be 0 where matrix S contains a regional max
for i = 1:N
    A = (TM == i) + S; % Get ith layer in Time Matrix; add to S
    L = bwlabel(A); % Label ith Layer
    % Filter by Areas, Eccentricity
    B = regionprops(L,'All');
    objects = (([B.Area] < 220) & ([B.Eccentricity] < 0.85));
    % Obtain Mask with Possible Nuclei
    N = imfill(ismember(L, find(objects)),'holes');
    % imwrite(N, ['N_' num2str(i) '.png'], 'png');
    % Store possible nuclei
    S(N == 1) = 1;
    % imwrite(S, ['S_' num2str(i) '.png'], 'png');
end

imwrite(S, 'Mask.png', 'png');
% S = imregionalmax(T);

if bg_kill == 'Y'
    disp('#DELETING BACKGROUND');
    set(lb, 'String', cmdwinout());
    % Otsu's Method Fix; Eliminates all black pixels
    O = S.*d_mask;
    O = S(S==O);

    % Delete Background
    S = S.*d_mask;
else
    O = S;
end

% Y = im2bw(S,graythresh(S));
Y = S;

% Filters
% Eliminate pixels on border
Y1 = cut_mask.*Y;
% se = strel('disk',1);
% output = imerode(Y1,se);

% % Watershed Algorithm
% % Get Internal Markers
% IM = output; % Internal Markers
% % imwrite(IM,'IM.png','png');
% % Get Complement
% I_c = 1 - double(I_F)/max(I_F(:));
% % Apply impose min with output mask
% IMA = imimposemin(I_c,output);
% % Get External Markers
% se = strel('disk', 2);
% IMA = imimposemin(IMA, bwperim(imdilate(output,se)));
% % imwrite(bwperim(imdilate(output,se)), 'BW.png', 'png');
% EM = (watershed(IMA) == 0); % External Markers
% % imwrite(EM,'EM.png','png');
% % Apply IM and EM
% markers = IM | EM;
% % Overlay markers on original image
% r = I_c; g = I_c; b = I_c;
% r(markers) = 1; g(markers) = 0; b(markers) = 0;
% rgb = cat(3,r,g,b);
% imwrite(rgb, 'rgb.png', 'png');
% % Watershed
% [G, ~] = imgradient(medfilt2(I_c)); % Sobel Gradient
% G = imimposemin(G,markers); % Overlay Markers
% % imwrite(G/max(G(:)), 'G.png', 'png');
% output = imfill((watershed(G) == 0),'holes');

L = bwlabel(Y1,4);
B = regionprops(L,'Area');
objects = ([B.Area] > min_area) & ([B.Area] < max_area);
% objects = ([B.Area] < max_area);
areafilter = ismember(L, find(objects));
% figure, imshow(areafilter);
% imwrite(areafilter, '10_areafilter.png', 'png');

L = bwlabel(areafilter,4);
B = regionprops(L,'Eccentricity');
objects = ([B.Eccentricity] < eccen_limit);
efilter = ismember(L, find(objects));
% figure, imshow(efilter);
% imwrite(efilter, '11_efilter.png', 'png');

L = bwlabel(efilter,4);
B = regionprops(L,'Solidity');
objects = ([B.Solidity] > ap_min);
output = double(ismember(L, find(objects)));
% figure, imshow(Y);
imwrite(Y, 'geometricfilter.png', 'png');
% figure, imshow(output);

% Get object properties
L = bwlabel(output);
B = regionprops(L, I*255, 'All');
B2 = bg_finder(output, I*255, B);
object_props = [(0.5625*[B.Area])', [B.Eccentricity]', [B.Extent]',...
    [B.Solidity]', ([B.MeanIntensity])',...
    ((([B.MaxIntensity]-[B.MinIntensity])/4))',...
    ([B2.MeanIntensity])',...
    ((([B2.MaxIntensity]-[B2.MinIntensity])/4))'];
% object_props = [[B.Eccentricity]',...
%    [abs([B.MeanIntensity]-[B2.MeanIntensity])./sqrt(...
%    (([B.MaxIntensity]-[B.MinIntensity])/4).^2 + ...
%    (([B2.MaxIntensity]-[B2.MinIntensity])/4).^2)]'];
% % Apply Bayesian Classifier
% BC = bayes();
% % Modify Priors
% classified = BC.predict(object_props);
% for i=1:length(B)
%     if strcmp(classified{i},'nucleus')
%         output(L == i) = 1;
%     end
% end

% Apply Neural Network
load('data'); % Import pretrained network
classified = net(object_props');
output = zeros(size(L));
for i=1:length(classified)
    if (classified(i) >= 0.25)
        output = double(L == i) + output;
    end
end
imwrite(output,'output.png','png');
end