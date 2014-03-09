function [output] = normalize(A)
%normalize - Exactly what it says on the tin can
output = (A - min(A(:)))/(max(A(:)) - min(A(:)));
end