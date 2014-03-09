function [output] = fourierfilter(input_img, mask)
% fourierfilter Fourier Filter
%
% Uses Fourier Transform along with user-defined mask filter to filter
% an image

% Fourier Transform
disp('#APPLYING FOURIER TRANSFORM');
ft = fftshift(fft2(input_img));
% Real, Imaginary
ft_mag = abs(ft);
ft_phase = angle(ft);

% Normalize
disp('#APPLYING BAND PASS FILTER');
%figure, imshow(ft_mag,[]);
ft_mag_r = log(ft_mag + 1);
%figure, imshow(ft_mag_r, []);
ft_mag_r = ft_mag_r.*mask;
%figure, imshow(ft_mag_r, []);

% Return to Original Image
disp('#CONVERT BACK TO SPATIAL DOMAIN');
ft_mag = exp(ft_mag_r) - 1;
ft = ft_mag.*exp(1i*ft_phase);
transformed_image = real(ifft2(ifftshift(ft)));
output = transformed_image;
% figure, imshow(S);