% function anisodiff_med = anisodiff(frame, iterations, kappa, lambda, option, med, W)
%
%         frame         - input frame
%         iterations    - number of iterations.
%         kappa         - kappa from anisotropic diffusion eq, controls
%                         diffusion speed; a trade off between kappa and 
%                         iterations exists 
%         lambda        - lambda from anisotropic diffusion eq, 
%         edge detection function - 1 Perona Malik diffusion equation No 1
%                                   2 Perona Malik diffusion equation No 2
%                                   3 Tukey Bi-weight filter
%        med            - 1 for median filtering, 0 for no median
%        window_size    - size of median filter window
%
%
%
% Author:  Brette Luck
% Date: 10-5-2003
%   
% Based on a function by : Peter Kovesi   pk@cs.uwa.edu.au
% Department of Computer Science & Software Engineering
% The University of Western Australia   
%




function diff = anisodiff(frame, iterations, kappa, lambda, option, med, W)

if ndims(frame)==3
    error('Anisodiff only operates on 2D grey-scale images');
end

frame = double(frame);
[rows,cols] = size(frame);
diff = frame;

for i = 1:iterations
    %fprintf('\rIteration %d',i);
    
    % Construct diffl which is the same as diff but
    % has an extra padding of zeros around it.
    diffl = zeros(rows+2, cols+2);
    diffl(2:rows+1, 2:cols+1) = diff;
    
    % North, South, East and West differences
    deltaN = diffl(1:rows,2:cols+1)   - diff;
    deltaS = diffl(3:rows+2,2:cols+1) - diff;
    deltaE = diffl(2:rows+1,3:cols+2) - diff;
    deltaW = diffl(2:rows+1,1:cols)   - diff;
    
    % Conduction
    
    if option == 1
        cN = exp(-(deltaN/kappa).^2);
        cS = exp(-(deltaS/kappa).^2);
        cE = exp(-(deltaE/kappa).^2);
        cW = exp(-(deltaW/kappa).^2);
    elseif option == 2
        cN = 1./(1 + (deltaN/kappa).^2);
        cS = 1./(1 + (deltaS/kappa).^2);
        cE = 1./(1 + (deltaE/kappa).^2);
        cW = 1./(1 + (deltaW/kappa).^2);
    elseif option == 3
        
        cN = zeros(size(diff));
        cS = zeros(size(diff));
        cE = zeros(size(diff));
        cW = zeros(size(diff));
        
        cN(find(abs(deltaN)<sqrt(5).*kappa)) = 25/16/kappa.*(1-(deltaN(find(abs(deltaN)<sqrt(5).*kappa))/sqrt(5)/kappa).^2).^2;
        cS(find(abs(deltaS)<sqrt(5).*kappa)) = 25/16/kappa.*(1-(deltaS(find(abs(deltaS)<sqrt(5).*kappa))/sqrt(5)/kappa).^2).^2;
        cE(find(abs(deltaE)<sqrt(5).*kappa)) = 25/16/kappa.*(1-(deltaE(find(abs(deltaE)<sqrt(5).*kappa))/sqrt(5)/kappa).^2).^2;
        cW(find(abs(deltaW)<sqrt(5).*kappa)) = 25/16/kappa.*(1-(deltaW(find(abs(deltaW)<sqrt(5).*kappa))/sqrt(5)/kappa).^2).^2;
        
    end
    
    diff = diff + lambda*(cN.*deltaN + cS.*deltaS + cE.*deltaE + cW.*deltaW);

    %for aniostropic median diffusion, median filter each window
    if med == 1
        diff = medfilt2(diff,[W W]);
    end
end

