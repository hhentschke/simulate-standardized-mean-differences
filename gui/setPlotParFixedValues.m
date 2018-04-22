function setPlotParFixedValues(hObject,handles)
% ** function setPlotParFixedValues(hObject,handles)
handles=guidata(handles.guiFigure);
simDs=handles.simDs;

[~,simDs.plotParFixedValIx(1)]=min(abs(simDs.(handles.parameter3Text.String)-handles.parameter3Slider.Value));
simDs.plotParFixedVal(1)=simDs.(handles.parameter3Text.String)(simDs.plotParFixedValIx(1));

[~,simDs.plotParFixedValIx(2)]=min(abs(simDs.(handles.parameter4Text.String)-handles.parameter4Slider.Value));
simDs.plotParFixedVal(2)=simDs.(handles.parameter4Text.String)(simDs.plotParFixedValIx(2));

% don't forget
handles.simDs=simDs;

guidata(handles.guiFigure,handles)