clc;
clear all;
close all;

%% Settings
% Sets the save name for the file
savefilename = '8bit_image';

%%

% Open Dialog Box
[filename, pathname, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'File Selector');

% Read in image file
I = imread([pathname filename]);

% Check if image is rgb
if (ndims(I) == 3) % Image is RGB
    % Check if image is unsigned 16 bit
    if isa(I,'uint16');
        output = uint8(double(I)); %Convert to double then to uint8
        imwrite(output,[savefilename '.tif'], 'tif',...
            'Resolution', [300 300]); % Save Iamge
    else
        disp('Object is not a unsigen 16 bit image.');
    end
elseif (ndims(I) == 2) % Image is grayscale
	% Check if image is unsigned 16 bit
    if isa(I,'uint16');
		% Convert to rgb
		I = cat(3,I,I,I);
        output = uint8(double(I)); %Convert to double then to uint8
        imwrite(output,[savefilename '.tif'], 'tif',...
            'Resolution', [300 300]); % Save Iamge
    else
        disp('Object is not a unsigen 16 bit image.');
    end
else
    disp('Image is not rgb or grayscale, load rgb or grayscale image.');
end