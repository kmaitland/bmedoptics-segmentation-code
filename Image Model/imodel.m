clc;
clear all;
close all;
%rng default; % Keeps randomizer the same through each program run

% Parameters
radius = ones(1,14)*5;
number = [1 5 12 18 25 27 28 29 32 31 27 13 2];
intensity = [118 141 165 188 212 ...
    235 259 282 306 329 353 376 400];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create empty matrix 
obj = zeros(1000,1000);

for n=1:length(number)
    for k=1:number(n)
        disp(['Bin #: ' num2str(n)]);
        disp(['Object # in Bin: ' num2str(k)]);
        % Do/While Loop
        condition = 1;
        while (condition == 1)
            % Store Previous Matrix
            p_obj = obj;
            % Make Object
            obj = circle(radius(n),obj,randi([30,970],1,1),...
                randi([30,970],1,1), p_obj, intensity(n));
            % Look at eccentricity; Make at least 5 pxls apart
            se = strel('disk',5);
            test = imdilate(obj,se);
            R = regionprops(bwconncomp(test),'Eccentricity');
            % Test for overlap
            if (sum([R.Eccentricity],2) == 0)
                % Exit when no overlap
                condition = 0;
            else
                % Use Previous Matrix
                obj = p_obj;
            end
        end
    end
end
 
% Display Object
obj = uint16(obj);
figure, imshow(obj,[]);

% Save image/matrix
% imwrite(obj,'image_model.png','png');
save('imagemodel.mat','obj');
% Apply noise to each each image using bg distribution