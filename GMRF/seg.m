clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GMRF LEVELS
GMRF_levels = 8;

% AREA FILTER CONSTRAINTS
max_size = 220;
min_size = 30;

% ECCENTRICITY FILTER
eccentricity = 0.85;

% SOLIDITY
solidity = 0.7;

% Excel Filename
xlssavename = 'results.xls';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[filename, pathname, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'File Selector', 'MultiSelect', 'on');

if ~isequal(filename, 0)
    % If filename not cell array, make cell array
    if ~iscell(filename)
        filename = {filename};
    end
    
    % Find the number of files opened
    num = size(filename ,2);
    
    % Create cell array
    img = cell(1, num);
    name = cell(1, num);
    mask = cell(1, num);
    raw_area = cell(1, num);
    area = zeros(1, num);
    area_sd = zeros(1, num);
    eccen = zeros(1, num);
    eccen_sd = zeros(1, num);
    objects = zeros(1, num);
    
    % Save each image/filename to memory
    for n=2:num+1
        img{n-1} = formatgrayscale(imread([pathname filename{n-1}]),'N');
        [path, name{n}, ~] = fileparts(filename{n-1});
        disp([name{n} ':']);
        [mask{n-1}, img_props] = GMRF_seg(img{n-1}, GMRF_levels,...
            max_size, min_size, eccentricity, solidity,...
            pathname, filename{n-1});
        
        % Values
        raw_area{n-1} = (0.5625*[img_props.Area])';
        area(n) = 0.5625*mean([img_props.Area]);
        area_sd(n) = 0.5625*std([img_props.Area]);
        eccen(n) = mean([img_props.Eccentricity]);
        eccen_sd(n) = std([img_props.Eccentricity]);
        objects(n) = length((1:size(img_props)));
        disp([num2str(area(n)), ' ', num2str(area_sd(n))]);
        disp([num2str(eccen(n)), ' ', num2str(eccen_sd(n))]);
        disp(num2str(objects(n)));
    end
    
    % Create table from data
    % Check if using PC
    if ispc()
        for i=2:num+1
            raw_area{i-1} = cellstr(num2str(raw_area{i-1}))';
        end
        area = num2cell(area);
        area_sd = num2cell(area_sd);
        eccen = num2cell(eccen);
        eccen_sd = num2cell(eccen_sd);
        objects = num2cell(objects);
    else
        for i=2:num+1
            raw_area{i-1} = cellstr(num2str(raw_area{i-1}))';
        end
        area = cellstr(num2str(area'))';
        area_sd = cellstr(num2str(area_sd'))';
        eccen = cellstr(num2str(eccen'))';
        eccen_sd = cellstr(num2str(eccen_sd'))';
        objects = cellstr(num2str(objects'))';
    end
    
    nameoffiles{1} = 'Image';
    area{1} = 'Average Area';
    area_sd{1} = 'SD Area';
    eccen{1} = 'Average Eccentricity';
    eccen_sd{1} = 'SD Eccentricity';
    objects{1} = '# of Objects';
    
    % Excel Data Table
    A = [(name)',(area)',(area_sd)',(eccen)',(eccen_sd)',(objects)'];

    % Create Empty Cell
    B = {};
    
    % Nuclei Area Data (Unaveraged)
    for k = 2:num+1
        B = [B; [cellstr(repmat(name{k},length(raw_area{k-1}),1)),...
            (raw_area{k-1})']];
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