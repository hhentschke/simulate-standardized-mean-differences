function setPlotParOrder(hObject,handles,varargin)
% ** function setPlotParOrder(hObject,handles,varargin)

simDs=handles.simDs;
% numerical values of available parameters
availablePlotPar=double(simDs.paramPointEstim);
if nargin>2 && ischar(varargin{1}) && strcmpi(varargin{1},'init')
  % set initial strings and values of listboxes and static texts (=fields of simDs)
  handles.parameter1Listbox.String=cellstr(simDs.paramPointEstim);
  handles.parameter1Listbox.Value=double(simDs.paramPointEstim(1));
  handles.parameter2Listbox.String=cellstr(simDs.paramPointEstim);
  handles.parameter2Listbox.Value=double(simDs.paramPointEstim(2));
  handles.parameter3Text.String=char(simDs.paramPointEstim(3));
  handles.parameter4Text.String=char(simDs.paramPointEstim(4));
else
  % logics of setting parameters in listboxes:
  % - if current choice is identical to that in the other listbox, set the
  % latter to a different value
  availablePlotPar=setdiff(availablePlotPar,hObject.Value);
  switch hObject.Tag
    case 'parameter1Listbox'
      otherList=handles.parameter2Listbox;
    case 'parameter2Listbox'
      otherList=handles.parameter1Listbox;
  end
  if hObject.Value==otherList.Value
    otherList.Value=availablePlotPar(1);
    availablePlotPar(1)=[];
  else
    availablePlotPar=setdiff(availablePlotPar,otherList.Value);
  end
  
  % now deal with static text fields
  handles.parameter3Text.String=char(simDs.paramPointEstim(availablePlotPar(1)));
  handles.parameter4Text.String=char(simDs.paramPointEstim(availablePlotPar(2)));

  % after all have been set...
  simDs.paramPointEstimPlotOrder=simDs.paramPointEstim([...
    handles.parameter1Listbox.Value; handles.parameter2Listbox.Value;...
    availablePlotPar]);
  simDs.paramCiPlotOrder=[simDs.paramPointEstimPlotOrder; simDs.paramCiPlotOrder(5:6)];
  availablePlotPar=[];
  % don't forget 
  handles.simDs=simDs;
end

% set values of sliders
set(handles.parameter3Slider,...
  'Min',min(simDs.(handles.parameter3Text.String)),...
  'Max',max(simDs.(handles.parameter3Text.String)),...
  'value',min(simDs.(handles.parameter3Text.String)));
set(handles.parameter4Slider,...
  'Min',min(simDs.(handles.parameter4Text.String)),...
  'Max',max(simDs.(handles.parameter4Text.String)),...
  'value',min(simDs.(handles.parameter4Text.String)));

% store
guidata(handles.guiFigure,handles);