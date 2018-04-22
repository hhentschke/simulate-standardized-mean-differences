function varargout = simulate_smd_plotControlGUI(varargin)
% SIMULATE_SMD_PLOTCONTROLGUI MATLAB code for simulate_smd_plotControlGUI.fig
%      SIMULATE_SMD_PLOTCONTROLGUI, by itself, creates a new SIMULATE_SMD_PLOTCONTROLGUI or raises the existing
%      singleton*.
%
%      H = SIMULATE_SMD_PLOTCONTROLGUI returns the handle to a new SIMULATE_SMD_PLOTCONTROLGUI or the handle to
%      the existing singleton*.
%
%      SIMULATE_SMD_PLOTCONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULATE_SMD_PLOTCONTROLGUI.M with the given input arguments.
%
%      SIMULATE_SMD_PLOTCONTROLGUI('Property','Value',...) creates a new SIMULATE_SMD_PLOTCONTROLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simulate_smd_plotControlGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simulate_smd_plotControlGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simulate_smd_plotControlGUI

% Last Modified by GUIDE v2.5 17-Apr-2018 22:47:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulate_smd_plotControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @simulate_smd_plotControlGUI_OutputFcn, ...
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


% --- Executes just before simulate_smd_plotControlGUI is made visible.
function simulate_smd_plotControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simulate_smd_plotControlGUI (see VARARGIN)

% Choose default command line output for simulate_smd_plotControlGUI
handles.output = hObject;
% handles to two figures to be used for plots
handles.figHandles=gobjects(3,1);
% initialize figures
scs=get(groot,'screensize');
marg=round(scs(4)/40);
for ii=1:numel(handles.figHandles)
  handles.figHandles(ii)=figure('position',...
    [350+ii*marg  floor(scs(4)*.25)-ii*marg   scs(3)*.6 floor(scs(4)*.75)-2*marg]);
  clf
end
% create field simDs
handles.simDs=[];
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = simulate_smd_plotControlGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% - clear all figures
% - load simDs from file and save to handles struct
% - initialize UIs with values from data 
for ii=1:numel(handles.figHandles)
  if isgraphics(handles.figHandles(ii))
    clf(handles.figHandles(ii))
  end
end
[dataFn,dataPathNm]=uigetfile('*.mat','Pick simulated data file');
if ~isempty(dataFn)
  s=whos('-file',[dataPathNm filesep dataFn]);
  if any(strcmp({s.name},'simDs'))
    load([dataPathNm filesep dataFn],'simDs');
    % make file name without extension a field of simDs so we can use it
    % for saving graphics
    [~,fn]=fileparts([dataPathNm filesep dataFn]);
    % set path & partial file name for saving figure files
    handles.figurePathFilenameEdit.String=[dataPathNm filesep fn];
    % next thing to do: save simDs to handles and update guidata because
    % functions setPlotOrder and setPlotParFixedValues below need access to
    % fields of simDs
    handles.simDs=simDs;
    guidata(handles.guiFigure,handles);
    % initialize controls for plots
    setPlotParOrder(hObject,handles,'init');
    % retrieve changes just made
    handles=guidata(handles.guiFigure);
    setPlotParFixedValues(hObject,handles);
    % retrieve changes just made
    handles=guidata(handles.guiFigure);
    % produce plots of effect size and coverage intervals as well as
    % summary boxplot of the latter
    simulate_smd_plot(handles,true);
  else
    warndlg('variable ''simDs'' not found in data file');
  end
end


% --- Executes on selection change in parameter1Listbox.
function parameter1Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to parameter1Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameter1Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameter1Listbox
setPlotParOrder(hObject,handles);
% redefine values for fixed parameters
setPlotParFixedValues([],handles);
simulate_smd_plot(handles);


% --- Executes during object creation, after setting all properties.
function parameter1Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter1Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in parameter2Listbox.
function parameter2Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to parameter2Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameter2Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameter2Listbox
setPlotParOrder(hObject,handles);
% redefine values for fixed parameters
setPlotParFixedValues([],handles);
simulate_smd_plot(handles);


% --- Executes during object creation, after setting all properties.
function parameter2Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter2Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function parameter3Slider_Callback(hObject, eventdata, handles)
% hObject    handle to parameter3Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
setPlotParFixedValues(hObject,handles);
simulate_smd_plot(handles);

% --- Executes during object creation, after setting all properties.
function parameter3Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter3Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function parameter4Slider_Callback(hObject, eventdata, handles)
% hObject    handle to parameter4Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
setPlotParFixedValues(hObject,handles);
simulate_smd_plot(handles);

% --- Executes during object creation, after setting all properties.
function parameter4Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter4Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in saveFigButton.
function saveFigButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveFigButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
typeGraphicsFile=handles.saveFigListbox.String{handles.saveFigListbox.Value};
print(handles.figHandles(1),['-d' typeGraphicsFile],...
  [handles.figurePathFilenameEdit.String  '_pointEstimate'])
print(handles.figHandles(2),['-d' typeGraphicsFile],...
  [handles.figurePathFilenameEdit.String  '_confInt'])
print(handles.figHandles(3),['-d' typeGraphicsFile],...
  [handles.figurePathFilenameEdit.String  '_confIntSum'])


% --- Executes on selection change in saveFigListbox.
function saveFigListbox_Callback(hObject, eventdata, handles)
% hObject    handle to saveFigListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns saveFigListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from saveFigListbox


% --- Executes during object creation, after setting all properties.
function saveFigListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFigListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function figurePathFilenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to figurePathFilenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of figurePathFilenameEdit as text
%        str2double(get(hObject,'String')) returns contents of figurePathFilenameEdit as a double


% --- Executes during object creation, after setting all properties.
function figurePathFilenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figurePathFilenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function guiFigure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to guiFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for k=1:numel(handles.figHandles)
  if ishandle(handles.figHandles(k))
    close(handles.figHandles(k))
  end
end
