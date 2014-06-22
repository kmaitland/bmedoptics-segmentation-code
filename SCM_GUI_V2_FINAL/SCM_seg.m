function varargout = SCM_seg(varargin)
% SCM_SEG MATLAB code for SCM_seg.fig
%      SCM_SEG, by itself, creates a new SCM_SEG or raises the existing
%      singleton*.
%
%      H = SCM_SEG returns the handle to a new SCM_SEG or the handle to
%      the existing singleton*.
%
%      SCM_SEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCM_SEG.M with the given input arguments.
%
%      SCM_SEG('Property','Value',...) creates a new SCM_SEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SCM_seg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SCM_seg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SCM_seg

% Last Modified by GUIDE v2.5 19-Jun-2014 12:20:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SCM_seg_OpeningFcn, ...
                   'gui_OutputFcn',  @SCM_seg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% DEFINE INITIAL VARIABLES/PARAMETERS HERE
% --- Executes just before SCM_seg is made visible.
function SCM_seg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SCM_seg (see VARARGIN)

% Choose default command line output for SCM_seg
handles.output = '';

% Adjust settings
clc;
warning off all;

% Initialize Variables
handles.img{1} = 'null';
handles.seg = 0;
handles.filename = 0;
handles.pathname = 0;
handles.num = 0;
handles.B = 0;

% Get String Value and convert to double
handles.gsv =@(x) str2double(get(x,'String'));

% Get centroid function
handles.gcv=@(x,n) x(n).Centroid;

% Clear Table
set(handles.uitable1, 'Data', handles.B);

% Command Window Read
set(handles.listbox2, 'String', cmdwinout());

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SCM_seg wait for user response (see UIRESUME)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = SCM_seg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%% END COMPUTER GENERATED CODE %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% START USER GENERATED CODE %%%%%%%%%%%%%%%%%%%%%%%%%

% Open Image
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.filename, handles.pathname, ~] = uigetfile({'*.png';'*.jpg';...
    '*.bmp';'*.tif;*.tiff';}, 'File Selector', 'MultiSelect', 'on');

if ~isequal(handles.filename, 0)
    
    % If filename not cell array, make cell array
    if ~iscell(handles.filename)
        handles.filename = {handles.filename};
    end
    
    % Find the number of files opened
    handles.num = size(handles.filename ,2);
    
    % Create cell array
    handles.img = cell(1, handles.num);
    name = cell(1, handles.num);
    
    % Save each image/filename to memory
    for n=1:handles.num
        handles.img{n} = imread([handles.pathname handles.filename{n}]);
        [path, name{n}, ~] = fileparts(handles.filename{n}); %#ok<ASGLU>
    end
    
    % Output List of images to listbox
    set(handles.listbox1, 'string', name);
    imshow(handles.img{1});
    handles.B = cell(handles.num+1);
    [handles.B{:}] = deal(0);
    set(handles.uitable1, 'Data', 0);
    handles.outputimg = handles.img;
    
    disp('#Files Selected!');
    set(handles.listbox2, 'String', cmdwinout());
else
    disp('#No Files Selected!');
    set(handles.listbox2, 'String', cmdwinout());
end

% Update variables to figure
set(handles.listbox2,'Value', length(cmdwinout()));
guidata(hObject, handles);

% Segment Image
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~strcmp(handles.img{1}, 'null') && ~strcmp(handles.img{1}, 'segmented')
    
    % Initialize Varaibles
    handles.centroid = cell(1, handles.num);
    raw_area = cell(1, handles.num);
    obj_intensity = cell(1, handles.num);
    sd_obj_intensity = cell(1, handles.num);
    bg_intensity = zeros(1, handles.num+1);
    sd_bg_intensity = zeros(1, handles.num+1);
    NCR = zeros(1, handles.num+1);
    numberofobjects = zeros(1, handles.num+1);
    mean_area = zeros(1, handles.num+1);
    std_area = zeros(1, handles.num+1);
    mean_eccentricity = zeros(1, handles.num+1);
    std_eccentricity = zeros(1, handles.num+1);
    nameoffiles = cell(1, handles.num+1);
    
    % Choose Save Directory, if Save Image is TRUE
    if get(handles.checkbox1,'Value')
        savedirectory = uigetdir(handles.pathname, 'Directory to Save');
    
        % Check if got directory successfully
        if savedirectory(1) ~= 0
        
        [xlssavename, xlspath, ~] = uiputfile({'*.xls';},...
            'Name Excel File', savedirectory);
        
            % Check if valid filename
            if (xlssavename(1) ~= 0) && (xlspath(1) ~= 0)
            % Excel Filename Failed
            else
                disp('#Invalid xls filename');
                set(handles.listbox2, 'String', cmdwinout());
                return;
            end
        
        % No Directory Chosen or Invalid Directory
        else
            disp('#Invalid or No Directory Chosen');
            set(handles.listbox2, 'String', cmdwinout());
            return;
        end
    end
            
    % Create waitbar
    h = waitbar(0, 'Segmenting Image(s)');

    % Create cells for segmented images
    handles.seg = cell(1, handles.num);

    % Get Parameters specified in options panel
    handles.maxarea = handles.gsv(handles.edit6);
    handles.minarea = handles.gsv(handles.edit8);
    handles.eccentricity = handles.gsv(handles.edit9);
    handles.solidity = handles.gsv(handles.edit11);
    handles.rb = handles.gsv(handles.edit16);
    handles.lateralres = handles.gsv(handles.edit17);
    handles.res = (handles.gsv(handles.edit18)).^2;
    
    for n=1:handles.num
        % Segmentation
        I = formatgrayscale(handles.img{n}, 'N');
        I = imcrop(double(I)/255,[1 1 999 999]);
        [w, l] = size(I);
        
        if ~get(handles.checkbox4,'Value')
            bg_area = 1000000;
            d_mask = ones(w,l);
            cut_mask = d_mask;
        else
            [~, bg_area, d_mask] = bg_remove(I, handles.listbox2);
            se = strel('disk',handles.rb);
            cut_mask = imerode(d_mask,se);
        end
        [filter_img, I_crop] = SCM(I, w, l,...
            handles.maxarea, handles.minarea,...
            handles.eccentricity, handles.solidity, 'Y',...
            d_mask, cut_mask, handles.lateralres, handles.listbox2);
                
        % Update variables to figure
        set(handles.listbox2,'Value', length(cmdwinout()));
        guidata(hObject, handles);
        
        % Outline Image
        BWoutline = bwperim(filter_img);
        Segout_R = I_crop; Segout_R(BWoutline) = 255;
        Segout_G = I_crop; Segout_G(BWoutline) = 0;
        Segout_B = I_crop; Segout_B(BWoutline) = 0;
        if get(handles.checkbox4,'Value')
            BGoutline = bwperim(d_mask);
            Segout_B(BGoutline) = 255;
        end
        handles.seg{n} = cat(3, Segout_R, Segout_G, Segout_B);
        % imwrite(handles.seg{n}, '13_segmentedimage.png', 'png');
        
        % Get Image Info
        prop = regionprops(bwconncomp(filter_img), I, 'All');
        
        % Get 2 - 5 pixels from objects for bg
        se1 = strel('disk',5);
        se2 = strel('disk',2);
        bg = imdilate(filter_img,se1) - imdilate(filter_img,se2);
        prop2 = regionprops(bwconncomp(bg), I, 'All');
        
        % Save prop to get centroid for each object
        handles.centroid{n} = prop;
        
        % Get area and sd area for each object
        raw_area{n} = (handles.lateralres*[prop.Area])';
        
        % Get intensity and sd intensity for each object
        obj_intensity{n} = ([prop.MeanIntensity])';
        sd_obj_intensity{n} = ([prop.MaxIntensity]-[prop.MinIntensity])'/4;
        
        % Get bg intensity and sd bg intensity
        bg_intensity(n+1) = mean([prop2.MeanIntensity]);
        sd_bg_intensity(n+1) = mean(([prop2.MaxIntensity]...
            -[prop2.MinIntensity])'/4);
        
        % Get NCR, # of obj, mean area, sd area, mean eccen, sd eccen
        NCR(n+1) = sum([prop.Area])/(bg_area - sum([prop.Area]));
        numberofobjects(n+1) = length((1:size(prop)));
        mean_area(n+1) = handles.lateralres*mean([prop.Area]);
        std_area(n+1) = handles.lateralres*std([prop.Area]);
        mean_eccentricity(n+1) = mean([prop.Eccentricity]);
        std_eccentricity(n+1) = std([prop.Eccentricity]);

        % Save Image
        [path, name, ~] = fileparts(handles.filename{n}); %#ok<ASGLU>
        disp(['#Saving Image... ' name]);
        set(handles.listbox2, 'String', cmdwinout());
        
        % Update variables to figure
        set(handles.listbox2,'Value', length(cmdwinout()));
        guidata(hObject, handles);
        
        % Save Image to file
        if get(handles.checkbox1,'Value')
            if ispc()
                imwrite(handles.seg{n}, [savedirectory '\seg_' name...
                '.tif' ], 'tif', 'Resolution', [handles.res handles.res]);
            else
                imwrite(handles.seg{n}, [savedirectory '/seg_' name...
                '.tif' ], 'tif', 'Resolution', [handles.res handles.res]);
            end
        end
            
        % Index Filename
        nameoffiles{n+1} = name;

        % Update waitbar()
        waitbar(n/handles.num);
    end
    
    % Create table from data
    for i=2:handles.num+1
            raw_area{i-1} = cellstr(num2str(raw_area{i-1}))';
            obj_intensity{i-1} = cellstr(num2str(obj_intensity{i-1}))';
            sd_obj_intensity{i-1} = cellstr(...
                num2str(sd_obj_intensity{i-1}))';
    end
    % Check if using PC
    if ispc()
        NCR = num2cell(NCR);
        numberofobjects = num2cell(numberofobjects);
        mean_area = num2cell(mean_area);
        std_area = num2cell(std_area);
        mean_eccentricity = num2cell(mean_eccentricity);
        std_eccentricity = num2cell(std_eccentricity);
        bg_intensity = num2cell(bg_intensity);
        sd_bg_intensity = num2cell(sd_bg_intensity);
    else
        NCR = cellstr(num2str(NCR'))';
        numberofobjects = cellstr(num2str(numberofobjects'))';
        mean_area = cellstr(num2str(mean_area'))';
        std_area = cellstr(num2str(std_area'))';
        mean_eccentricity = cellstr(num2str(mean_eccentricity'))';
        std_eccentricity = cellstr(num2str(std_eccentricity'))';
        bg_intensity = cellstr(num2str(bg_intensity'))';
        sd_bg_intensity = cellstr(num2str(sd_bg_intensity'))';
    end
    
    % Set names for data table display
    nameoffiles{1} = 'Image';
    NCR{1} = 'NCR';
    numberofobjects{1} = '# of Objects';
    mean_area{1} = 'Average Area';
    std_area{1} = 'SD Area';
    mean_eccentricity{1} = 'Average Eccentricity';
    std_eccentricity{1} = 'SD Eccentricity';
    bg_intensity{1} = 'Mean BG Intensity';
    sd_bg_intensity{1} = 'SD BG Intensity';
    
    % Data Table Display
    handles.B = [(nameoffiles); (NCR);...
        (numberofobjects); (mean_area); (std_area);...
        (mean_eccentricity); (std_eccentricity);...
        (bg_intensity); (sd_bg_intensity);];

    if get(handles.checkbox1,'Value')
        % Excel Data Table
        A = [(nameoffiles)', (NCR)',...
            (numberofobjects)', (mean_area)', (std_area)',...
            (mean_eccentricity)', (std_eccentricity)',...
            (bg_intensity)', (sd_bg_intensity)'];
        
        % Create Empty Cell
        C = {};
        
        % Nuclei Area Data (Unaveraged)
        for k = 2:((handles.num)+1)
        C = [C; [cellstr(repmat(nameoffiles{k},...
            length(raw_area{k-1}),1)),(raw_area{k-1})',...
            (obj_intensity{k-1})',(sd_obj_intensity{k-1})',...
            cellstr(num2str((1:length(raw_area{k-1}))'))]]; %#ok<AGROW>
        end
        
        % Write to spreadsheet
        if ispc
            xlswrite([xlspath xlssavename], A);
            
            % Nuclei Area Data (Unaveraged)    
            xlswrite([xlspath 'raw_data.xls'], C);
        else
            fid=fopen([xlspath strtok(xlssavename, '.') '.csv'],'wt');

            [rows, ~]=size(A);

            for i=1:rows
                fprintf(fid,'%s,',A{i,1:end-1});
                fprintf(fid,'%s\n',A{i,end});
            end

            fclose(fid);
            
            % Nuclei Area Data (Unaveraged)
            fid=fopen([xlspath strtok('raw_data.xls', '.') '.csv'],'wt');

            [rows, ~]=size(C);

            for i=1:rows
                fprintf(fid,'%s,',C{i,1:end-1});
                fprintf(fid,'%s\n',C{i,end});
            end

            fclose(fid); 
        end
    end
    
    % Show Image and close loading bar
    disp('#DONE!');
    set(handles.listbox2, 'String', cmdwinout());
    close(h);
    imshow(handles.seg{n});
    
    % Label Objects
%     hold on;
%     for k = 1:numel(handles.centroid{n})
%         x = handles.gcv(handles.centroid{n},k);
%         text(x(1),x(2),sprintf('%d',k),...
%             'HorizontalAlignment', 'center',...
%             'VerticalAlignment', 'middle',...
%             'Color', [1,0.6,0]);
%     end
%     hold off;
    
    % Display table
    set(handles.uitable1, 'Data', [handles.B(:,1) handles.B(:,n+1)]);
    handles.outputimg = handles.seg;
    handles.img = {'segmented'};

elseif strcmp(handles.img{1}, 'segmented')
    disp('#Image(s) already segmented, load new image(s) to segment');
    set(handles.listbox2, 'String', cmdwinout());
else
    disp('#No Image Loaded, Open Image First!');
    set(handles.listbox2, 'String', cmdwinout());
end

% Update variables to figure
set(handles.listbox2,'Value', length(cmdwinout()));
guidata(hObject, handles);

% Open Settings Panel
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.uipanel3, 'Visible'),'off')
    set(handles.uipanel3, 'Visible', 'on');
else
    set(handles.uipanel3, 'Visible', 'off');
end
    
% Selection Listbox
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Get current selected image
index = get(handles.listbox1,'value');

% Display current selected image
imshow(handles.outputimg{index});

% % Label Objects
% hold on;
% for k = 1:numel(handles.centroid{index})
%     x = handles.gcv(handles.centroid{index},k);
%     text(x(1),x(2),sprintf('%d',k),...
%         'HorizontalAlignment', 'center',...
%         'VerticalAlignment', 'middle',...
%         'Color', [1,0.6,0]);
% end
% hold off;

% Set data table
set(handles.uitable1, 'Data', [handles.B(:,1) handles.B(:,index+1)]);

% update variables
guidata(hObject, handles);
    
% Exit Attempt
% --- Executes when user attempts to close mainbox.
function mainbox_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
    delete(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

% Exit
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.mainbox, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(handles.mainbox);
    delete(handles.mainbox);
else
    % The GUI is no longer waiting, just close it
    delete(handles.mainbox);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NOT USED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox1

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
