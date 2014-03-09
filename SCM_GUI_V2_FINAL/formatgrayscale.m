function image = formatgrayscale(input, invert)

% This function corrects the format of the input image for program
% processing by converting the image to grayscale.
%
% It also inverts the image as specified by the invert variable (Y/N).
%
% If the image is already grayscale, this function will ignore it.
%
% Note: Certain tiff files (particularly those with CMYK channels) will
% NOT work with this function. In those cases, you must convert the file 
% manually (ex. photoshop).
%
% By Andrew Van (2012)

disp('#CHECKING FORMAT')

% Invert Image
if invert == 'Y'
    input = imcomplement(input);
    disp('#INVERTING IMAGE')
end
%figure, imshow(input), title('Original Image');

% If Image is not GreyScale
if ndims(input) == 3
    disp('#IMAGE IS NOT GRAYSCALE')
    %Convert Image to GreyScale
    disp('#CONVERTING TO GRAYSCALE')
    image = rgb2gray(input);
    %figure, imshow(I), title('Greyscale Image');

% Image is already GreyScale    
elseif ndims(input) == 2
    disp('#IMAGE ALREADY GRAYSCALE')
    image = input;
    
% Invalid image format
else
    disp('#Error Invalid Image Format\nFile must be grayscale or RGB');
end