function S = GMRF(input_image, s, r)

% This function is a modified version of a GMRF filter created
% by Brett Luck.
%
% The following code is based on:
%       F.R. Hanson, H. Elliot, "Image Segmentation Using Simple Markov
%       Field Models," Computer Graphics and Image Processing, vol. 20, 
%       pp. 101-32, 1982.
% for an unspecified input image with standard deviation s
%
% Created by Brett Luck (2003)
% Modified by Andrew Van (2012)

disp('CALCULATING GMRF')

% Convert 
input_image = double(input_image);

%-------------------------------
% initalize the variables
%-------------------------------
disp('---INITIALIZING')
T = .95;
[N1,N2] = size(input_image);

R = length(r);
D = zeros(N1,N2,R);

for i=1:N1
    for j=1:N2
        for k=1:R
            D(i,j,k) = -1/2/s*(input_image(i,j)-r(k)).^2;
        end
    end
end

pi = log(1-T).*(ones(R)-eye(R)) + log(T).*eye(R);

l = zeros(N1,N2,R);
g = zeros(N1,N2,R);

%------------------------
% Step 1
%------------------------
disp('---3')
c = 1;
l(c,:,:) = D(1,:,:);

%------------------------
% Step 2
%------------------------
disp('---2')
 for c = 2:N1;   
     for i = 1:R
         temp = shiftdim(l(c-1,:,:),1)+shiftdim(repmat(D(c,:,i),[1 1 R]),1)+repmat(pi(i,:),[N2,1]);        
         [l(c,:,i)  g(c-1,:,i)] = max(temp');
     end
 end

%------------------------
% Step 5
%------------------------
disp('---1')
[~, S] = max(l,[],3);

%------------------------
% Step 4
%------------------------
disp('---0')
[~, p]= max(l(N1,:,:),[],3);
S(N1,:) = p;

% convert back to input
z = zeros(size(S));
r = ceil(linspace(0, 255, R));
for i = 1:R
    z(S == i) = r(i);
end
S = uint8(round(z));
disp('---GMRF CALCULATED')