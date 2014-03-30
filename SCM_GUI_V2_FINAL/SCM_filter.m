function [S_new] = SCM_filter(S)

[width, height] = size(S);

% Median filter the image
S = medfilt2(S);

% Step 1 - Initialize Parameters
T = zeros(width, height);
U = zeros(width, height);
E = zeros(width, height);
Y = zeros(width, height);
alpha_f = 0.1; % alpha_f
f = exp(-alpha_f); % exp(-alpha_f)
b = 0.25; % Beta
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
end

% Erase pixels that with no values in the time matrix
S_new = (~(T == 0)).*S;

% Lower intensities of saturated bright areas that cannot be nuclei
dark = double(T == 2);
% % Area
L = bwlabel(dark);
B = regionprops(L,'Area');
objects = ([B.Area] > 220);
bright = ismember(L, find(objects));

% Look for dark spots with potential to be nuclei
dark = double(T == 3 | T == 4 | T == 5 | T == 6);
se = strel('disk', 5);
dark = imfill(imclose(dark, se), 'holes');
% Area
L = bwlabel(dark);
B = regionprops(L,'Area');
objects = ([B.Area] < 220 & [B.Area] > 30);
dark = ismember(L, find(objects));
% Eccentricity
L = bwlabel(dark);
B = regionprops(L,'Eccentricity');
objects = ([B.Eccentricity] < 0.75);
dark = ismember(L, find(objects));
 
% Darken/Brighted those spots
mask = double(bright).*double(T==2);
mask2 = double(dark).*double(T == 3 | T == 4 | T == 5 | T == 6);
S_new = S_new.*double(~mask) + (S_new.^2).*double(mask);
S_new = S_new.*double(~mask2) + (S_new.^0.5).*double(mask2);

end