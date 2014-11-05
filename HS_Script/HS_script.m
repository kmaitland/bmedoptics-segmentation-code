clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Erodes segmentation mask by one pixel ('Y' or 'N')
erode = 'N';

% Enable/Disable background remover ('Y' or 'N', enables/disables the background remover function)
bgr = 'Y';

% Show Figure ('Y' or 'N', outputs figure of the segmented image)
show_fig = 'N';

% Excel Filename
xlssavename = 'results.xls';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open Segmented Files
[filename, pathname, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'File Selector', 'MultiSelect', 'on');

% Open Original Files
[filename2, pathname2, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'File Selector', 'MultiSelect', 'on');

if ~isequal(filename, 0)
    % If filename not cell array, make cell array
    if ~iscell(filename)
        filename = {filename};
        filename2 = {filename2};
    end
    
    % Find the number of files opened
    num = size(filename ,2);
    
    % Create cell array
    img = cell(1, num);
    oimg = cell(1, num);
    name = cell(1, num);
    mask = cell(1, num);
    raw_area = cell(1, num);
    raw_eccen = cell(1,num);
    extent = cell(1,num);
    solidity = cell(1,num);
    obj_intensity = cell(1, num);
    sd_obj_intensity = cell(1, num);
    bg_intensity = cell(1, num);
    sd_bg_intensity = cell(1, num);
    NCR = zeros(1, num);
    area = zeros(1, num);
    area_sd = zeros(1, num);
    eccen = zeros(1, num);
    eccen_sd = zeros(1, num);
    objects = zeros(1, num);
    
    % Save each image/filename to memory
    for n=2:num+1
        img{n-1} = imcrop(imread([pathname filename{n-1}]),[1,1,999,999]);
        oimg{n-1} = imcrop(formatgrayscale(imread([pathname2,...
            filename2{n-1}]),'N'),[1,1,999,999]);
        [path, name{n}, ~] = fileparts(filename{n-1});
        disp([name{n} ':']);
        [mask{n-1}, img_props] = create_mask(img{n-1}, oimg{n-1},...
            erode, show_fig);
        
        if strcmp(bgr,'N')
            bg_area = sum(sum(double((~mask{n-1}))));
        else
            [~, bg_area, ~] = bg_remove(oimg{n-1});
            bg_area = bg_area - sum(sum(double(mask{n-1})));
        end
        
        % Get background by dilating nuclei a few pixels out; do for each
        % individual object
        labeled_mask = bwlabel(mask{n-1});
        img_props2 = img_props; % Make same size
        for a=1:length(img_props)
            s_obj = (labeled_mask == a);
            se1 = strel('disk',5);
            se2 = strel('disk',2);
            bg = imdilate(s_obj,se1) - imdilate(s_obj,se2);
            if show_fig == 'Y'
                figure, imshow(bg);
            end
            disp(a);
            v = regionprops(bwconncomp(bg), oimg{n-1}, 'All');
            if (length(v) == 1)
                img_props2(a,1) = v;
            else
                img_props2(a,1) = v(1,1);
            end
        end
        
        % Values
        raw_area{n-1} = (0.5625*[img_props.Area])';
        raw_eccen{n-1} = ([img_props.Eccentricity])';
        extent{n-1} = ([img_props.Extent])';
        solidity{n-1} = ([img_props.Solidity])';
        obj_intensity{n-1} = ([img_props.MeanIntensity])';
        sd_obj_intensity{n-1} = ([img_props.MaxIntensity]...
            -[img_props.MinIntensity])'/4;
        bg_intensity{n-1} = ([img_props2.MeanIntensity])';
        sd_bg_intensity{n-1} = ([img_props2.MaxIntensity]...
            -[img_props2.MinIntensity])'/4;
        area(n) = 0.5625*mean([img_props.Area]);
        area_sd(n) = 0.5625*std([img_props.Area]);
        eccen(n) = mean([img_props.Eccentricity]);
        eccen_sd(n) = std([img_props.Eccentricity]);
        objects(n) = length((1:size(img_props)));
        NCR(n) = sum([img_props.Area])/(bg_area);
        disp([num2str(area(n)), ' ', num2str(area_sd(n))]);
        disp([num2str(eccen(n)), ' ', num2str(eccen_sd(n))]);
        disp([num2str(objects(n))]);
    end
    
    % Create table from data
    for i=2:num+1
            raw_area{i-1} = cellstr(num2str(raw_area{i-1}))';
            raw_eccen{i-1} = cellstr(num2str(raw_eccen{i-1}))';
            extent{i-1} = cellstr(num2str(extent{i-1}))';
            solidity{i-1} = cellstr(num2str(solidity{i-1}))';
            obj_intensity{i-1} = cellstr(num2str(obj_intensity{i-1}))';
            sd_obj_intensity{i-1} = cellstr(num2str(...
            sd_obj_intensity{i-1}))';
            bg_intensity{i-1} = cellstr(num2str(bg_intensity{i-1}))';
            sd_bg_intensity{i-1} = cellstr(num2str(...
            sd_bg_intensity{i-1}))';
    end
    % Check if using PC
    if ispc()
        NCR = num2cell(NCR);
        area = num2cell(area);
        area_sd = num2cell(area_sd);
        eccen = num2cell(eccen);
        eccen_sd = num2cell(eccen_sd);
        objects = num2cell(objects);
    else
        NCR = cellstr(num2str(NCR'))';
        area = cellstr(num2str(area'))';
        area_sd = cellstr(num2str(area_sd'))';
        eccen = cellstr(num2str(eccen'))';
        eccen_sd = cellstr(num2str(eccen_sd'))';
        objects = cellstr(num2str(objects'))';
    end
    
    nameoffiles{1} = 'Image';
    NCR{1} = 'NCR';
    area{1} = 'Average Area';
    area_sd{1} = 'SD Area';
    eccen{1} = 'Average Eccentricity';
    eccen_sd{1} = 'SD Eccentricity';
    objects{1} = '# of Objects';
    
    % Excel Data Table
    A = [(name)', (NCR)', (area)',(area_sd)',...
        (eccen)',(eccen_sd)',(objects)'];

    % Create Empty Cell
    B = {};
    
    % Nuclei Area Data (Unaveraged)
    for k = 2:num+1
        B = [B; [cellstr(repmat(name{k},length(raw_area{k-1}),1)),...
            (raw_area{k-1})',(raw_eccen{k-1})',(extent{k-1})',...
            (solidity{k-1})',(obj_intensity{k-1})',...
            (sd_obj_intensity{k-1})',(bg_intensity{k-1})',...
            (sd_bg_intensity{k-1})'...
            cellstr(num2str((1:length(raw_area{k-1}))'))]]; %#ok<AGROW>
    end
    
    % Write to spreadsheet
    if ispc
        xlswrite([pathname xlssavename], A);
        
        % Nuclei Area Data (Unaveraged)    
        xlswrite([pathname 'raw_area.xls'], B);
    else
        % Excel Data Table
        fid=fopen([pathname strtok(xlssavename, '.') '.csv'],'wt');

        [rows, ~]=size(A);

        for i=1:rows
            fprintf(fid,'%s,',A{i,1:end-1});
            fprintf(fid,'%s\n',A{i,end});
        end

        fclose(fid);
        
        % Nuclei Area Data (Unaveraged)
        fid=fopen([pathname strtok('raw_area.xls', '.') '.csv'],'wt');

        [rows, ~]=size(B);

        for i=1:rows
            fprintf(fid,'%s,',B{i,1:end-1});
            fprintf(fid,'%s\n',B{i,end});
        end

        fclose(fid); 
    end
    
else 
    disp('No Files Selected!');
end
