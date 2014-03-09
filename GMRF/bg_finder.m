function [img_props2] = bg_finder(mask, oimg, img_props)
%bg_finder
%   Get background by dilating nuclei a few pixels out; do for each
%   individual object

labeled_mask = bwlabel(mask);
img_props2 = img_props; % Make same size
for a=1:length(img_props)
    disp(['Object Search: ' num2str(a)]);
    s_obj = (labeled_mask == a);
    se1 = strel('disk',5);
    se2 = strel('disk',2);
    bg = imdilate(s_obj,se1) - imdilate(s_obj,se2);
    v = regionprops(bwconncomp(bg), oimg, 'All');
    if (length(v) == 1)
        img_props2(a,1) = v;
    else
        img_props2(a,1) = v(1,1);
    end
end

end