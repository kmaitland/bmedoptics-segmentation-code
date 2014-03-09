function [ output ] = circle(radius, image, width, height)
%CIRCLE Create circle
%   Basically draw a circle for FFT filtering
%   Takes radius, image, and dimensions of image for
%   filtering as arguments

value = 1;
output = zeros(size(image));
xc = int16(width/2);
yc = int16(height/2);
x = int16(0);
y = int16(radius);
d = int16(1 - radius);
output(xc, yc+y) = value;
output(xc, yc-y) = value;
output(xc+y, yc) = value;
output(xc-y, yc) = value;
while ( x < y - 1 )
    x = x + 1;
    if ( d < 0 ) 
        d = d + x + x + 1;
    else 
        y = y - 1;
        a = x - y + 1;
        d = d + a + a;
    end
output( x+xc,  y+yc) = value;
output( y+xc,  x+yc) = value;
output( y+xc, -x+yc) = value;
output( x+xc, -y+yc) = value;
output(-x+xc, -y+yc) = value;
output(-y+xc, -x+yc) = value;
output(-y+xc,  x+yc) = value;
output(-x+xc,  y+yc) = value;
end


end

