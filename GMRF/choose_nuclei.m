function nuclei = choose_nuclei(GMRF_frame, max_size, min_size)

% function nuclei = choose_nuclei(GMRF_frame)
%
% This function sellects objects in Gaussian Markov random fields 
% that are smaller than the maximum nuclear size (MAX_SIZE) and 
% lager than the center to center spacing (MIN_SIZE)
%
% Author: Brette Luck
% Modified by Andrew Van

disp('APPLYING SIZE FILTER')

layers = 8;

disp('---INITITALIZING')
% Get dimensions of GMRF_Frame; Create matrix a (zero-filled) with same
% dims
a = zeros(size(GMRF_frame));
% Create vector x:
% [255   219   183   146   110    73    37     0]
x = ceil(linspace(255,0,layers));

disp('---3')
[w h] = size(GMRF_frame);
levels = zeros(w, h, layers);
for i = 1:layers
    % Compare GMRF matrix values with current x vector value
    % Insert 1 in same location
    % Ex. Value at GMRF_Frame(200,200) = 146; During i = 4, insert 1 in
    % a(200, 200)
    a(GMRF_frame==x(i)) = 1;
    % Three-dim matrix that stores layers of matrix a progressively
    % Brightest values, 255, are stored in first layer, then 219, etc. 
    levels(:,:,i) = a;
end

disp('---2')
% Create nuclei matrix; same size as matrix a
nuclei = zeros(size(a));

disp('---1')
% Filter each layer stored in 'levels', extracting objects within 
% min_size and max_size
disp('---EXTRACTING DATA FROM GMRF LAYERS')
for j = 1:layers
    L = bwlabel(levels(:,:,j),4);
    B = regionprops(L,'all');
    for i = 1:length(B)
        if (B(i).Area < max_size)
            if(B(i).Area > min_size)
                nuclei(L==i)=1;
            end
        end
    end
    disp(['------' num2str(8-j)])
end
disp('------DONE')
disp('---0')
disp('---FINISHED')