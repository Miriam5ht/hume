function varargout = sleepMontageEditor(varargin)
%%   Copyright (c) 2015 Jared M. Saletin, PhD and Stephanie M. Greer, PhD
%
%   This file is part of H�m�.
%   
%   H�m� is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
% 
%   H�m� is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License along
%   with H�m�.  If not, see <http://www.gnu.org/licenses/>.
%
%   H�m� is intended for research purposes only. Any commercial or medical
%   use of this software is prohibited. The authors accept no
%   responsibility for its use in this manner.
%%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sleepMontageEditor

% Last Modified by GUIDE v2.5 15-Jan-2015 22:35:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sleepMontageEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @sleepMontageEditor_OutputFcn, ...
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


% --- Executes just before sleepMontageEditor is made visible.
function sleepMontageEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sleepMontageEditor (see VARARGIN)
channelNames = {'Channel'};
handles.labels = {varargin{1}.EEG.chanlocs(:).labels};
channelNames = {channelNames{1} handles.labels{1:length(handles.labels)}}';
for ch=1:14
    eval(['set(handles.channel',num2str(ch),',''String'',channelNames);']);
end

defaultGridMat = {
    '-50'   [0 .5 0]
    '-25'   [0 .5 0]
    '0'     [0 .5 0]
    '25'    [0 .5 0]
    '50'    [0 .5 0]};

for i = 1:14

    eval(['handles.gridMat',num2str(i),' = defaultGridMat;']);

end

CurrMontage = varargin{1}.CurrMontage;

bigGridMat = CurrMontage.bigGridMat;
hideChs = CurrMontage.hideChans;
electrodes = flipud(CurrMontage.electrodes);
colors = flipud(CurrMontage.colors);
scale = flipud(CurrMontage.scale);
ampChs = CurrMontage.scaleChans;

handles.montage.bigGridMat = bigGridMat;
handles.montage.hideChans = hideChs;
handles.montage.electrodes = CurrMontage.electrodes;
handles.montage.colors = CurrMontage.colors;
handles.montage.scale = CurrMontage.scale;
handles.montage.scaleChans = ampChs;

errCode = 0;
for e=1:length(electrodes)

    i = find(ismember(handles.labels,electrodes{e}));
    if isempty(i)
        errCode=1;
        break
    end
    eval(['set(handles.channel',num2str(e),',''Value'',',num2str(i(1)+1),');']);
    eval(['set(handles.color',num2str(e),',''BackgroundColor'',[',num2str(colors{e}),']);']);

    eval(['scaleSet = get(handles.scale',num2str(e),', ''String'');']);
    i = find(ismember(scaleSet,scale{e}));
    eval(['set(handles.scale',num2str(e),',''Value'',',num2str(i(1)),');']);


end

for e = 1:length(hideChs)

    i = find(ismember(electrodes,hideChs{e}));
    if isempty(i)
        errCode=1;
        break
    end
    eval(['set(handles.hide',num2str(i),',''Value'', 1);']);

end

for e = 1:length(ampChs)

    i = find(ismember(electrodes,ampChs{e}));
    if isempty(i)
        errCode=1;
        break
    end
    
    eval(['set(handles.amp',num2str(i),',''Value'', 1);']);

    chanSet = bigGridMat(:,1);
    channel = find(ismember(chanSet,ampChs{e}));

    gridData = bigGridMat{channel,2};

    eval(['handles.gridMat',num2str(i),' = gridData;']);

end

% Choose default command line output for sleepMontageEditor
handles.output = hObject;

handles.fileName = get(varargin{1}.fileIN,'String');
[filepath, filename]  = fileparts(handles.fileName);
handles.fileName = filename;

% Update handles structure
guidata(hObject, handles);
if errCode == 1
    errordlg('Incompatable base montage. Reload a montage compatable with this file before re-loading Montage Editor','H�m� Montage Editor');
    
    return
end
uiwait(hObject);  

% UIWAIT makes sleepMontageEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sleepMontageEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if isfield(handles,'montage')
varargout{2} = handles.montage;
end
delete(handles.figure1);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel1.
function channel1_Callback(hObject, eventdata, handles)
% hObject    handle to channel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel1


% --- Executes during object creation, after setting all properties.
function channel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color1.
function color1_Callback(hObject, eventdata, handles)
% hObject    handle to color1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color1
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in amp1.
function amp1_Callback(hObject, eventdata, handles)
% hObject    handle to amp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp1


% --- Executes on button press in hide1.
function hide1_Callback(hObject, eventdata, handles)
% hObject    handle to hide1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide1


% --- Executes on selection change in channel2.
function channel2_Callback(hObject, eventdata, handles)
% hObject    handle to channel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel2


% --- Executes during object creation, after setting all properties.
function channel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel3.
function channel3_Callback(hObject, eventdata, handles)
% hObject    handle to channel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel3


% --- Executes during object creation, after setting all properties.
function channel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel4.
function channel4_Callback(hObject, eventdata, handles)
% hObject    handle to channel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel4


% --- Executes during object creation, after setting all properties.
function channel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel5.
function channel5_Callback(hObject, eventdata, handles)
% hObject    handle to channel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel5


% --- Executes during object creation, after setting all properties.
function channel5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel6.
function channel6_Callback(hObject, eventdata, handles)
% hObject    handle to channel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel6


% --- Executes during object creation, after setting all properties.
function channel6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel7.
function channel7_Callback(hObject, eventdata, handles)
% hObject    handle to channel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel7


% --- Executes during object creation, after setting all properties.
function channel7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel8.
function channel8_Callback(hObject, eventdata, handles)
% hObject    handle to channel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel8


% --- Executes during object creation, after setting all properties.
function channel8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel9.
function channel9_Callback(hObject, eventdata, handles)
% hObject    handle to channel9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel9


% --- Executes during object creation, after setting all properties.
function channel9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel10.
function channel10_Callback(hObject, eventdata, handles)
% hObject    handle to channel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel10


% --- Executes during object creation, after setting all properties.
function channel10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel11.
function channel11_Callback(hObject, eventdata, handles)
% hObject    handle to channel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel11


% --- Executes during object creation, after setting all properties.
function channel11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel12.
function channel12_Callback(hObject, eventdata, handles)
% hObject    handle to channel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel12


% --- Executes during object creation, after setting all properties.
function channel12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel13.
function channel13_Callback(hObject, eventdata, handles)
% hObject    handle to channel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel13


% --- Executes during object creation, after setting all properties.
function channel13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel14.
function channel14_Callback(hObject, eventdata, handles)
% hObject    handle to channel14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel14


% --- Executes during object creation, after setting all properties.
function channel14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color2.
function color2_Callback(hObject, eventdata, handles)
% hObject    handle to color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color3.
function color3_Callback(hObject, eventdata, handles)
% hObject    handle to color3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color3
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color4.
function color4_Callback(hObject, eventdata, handles)
% hObject    handle to color4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color4
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color5.
function color5_Callback(hObject, eventdata, handles)
% hObject    handle to color5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color5
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color6.
function color6_Callback(hObject, eventdata, handles)
% hObject    handle to color6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color6
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color7.
function color7_Callback(hObject, eventdata, handles)
% hObject    handle to color7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color7
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color8.
function color8_Callback(hObject, eventdata, handles)
% hObject    handle to color8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color8
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color9.
function color9_Callback(hObject, eventdata, handles)
% hObject    handle to color9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color9
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes on selection change in color10.
function color10_Callback(hObject, eventdata, handles)
% hObject    handle to color10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color10
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes on selection change in color11.
function color11_Callback(hObject, eventdata, handles)
% hObject    handle to color11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color11
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes on selection change in color13.
function color13_Callback(hObject, eventdata, handles)
% hObject    handle to color13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color13
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes on selection change in color14.
function color14_Callback(hObject, eventdata, handles)
% hObject    handle to color14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color14
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes during object creation, after setting all properties.
function color14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes on button press in amp2.
function amp2_Callback(hObject, eventdata, handles)
% hObject    handle to amp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp2


% --- Executes on button press in amp3.
function amp3_Callback(hObject, eventdata, handles)
% hObject    handle to amp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp3


% --- Executes on button press in amp4.
function amp4_Callback(hObject, eventdata, handles)
% hObject    handle to amp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp4


% --- Executes on button press in amp5.
function amp5_Callback(hObject, eventdata, handles)
% hObject    handle to amp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp5


% --- Executes on button press in amp6.
function amp6_Callback(hObject, eventdata, handles)
% hObject    handle to amp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp6


% --- Executes on button press in amp7.
function amp7_Callback(hObject, eventdata, handles)
% hObject    handle to amp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp7


% --- Executes on button press in amp8.
function amp8_Callback(hObject, eventdata, handles)
% hObject    handle to amp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp8


% --- Executes on button press in amp9.
function amp9_Callback(hObject, eventdata, handles)
% hObject    handle to amp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp9


% --- Executes on button press in amp10.
function amp10_Callback(hObject, eventdata, handles)
% hObject    handle to amp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp10


% --- Executes on button press in amp11.
function amp11_Callback(hObject, eventdata, handles)
% hObject    handle to amp11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp11


% --- Executes on button press in amp12.
function amp12_Callback(hObject, eventdata, handles)
% hObject    handle to amp12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp12


% --- Executes on button press in amp13.
function amp13_Callback(hObject, eventdata, handles)
% hObject    handle to amp13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp13


% --- Executes on button press in amp14.
function amp14_Callback(hObject, eventdata, handles)
% hObject    handle to amp14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp14


% --- Executes on button press in hide2.
function hide2_Callback(hObject, eventdata, handles)
% hObject    handle to hide2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide2


% --- Executes on button press in hide4.
function hide4_Callback(hObject, eventdata, handles)
% hObject    handle to hide4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide4


% --- Executes on button press in hide5.
function hide5_Callback(hObject, eventdata, handles)
% hObject    handle to hide5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide5


% --- Executes on button press in hide3.
function hide3_Callback(hObject, eventdata, handles)
% hObject    handle to hide3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide3


% --- Executes on button press in hide6.
function hide6_Callback(hObject, eventdata, handles)
% hObject    handle to hide6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide6


% --- Executes on button press in hide7.
function hide7_Callback(hObject, eventdata, handles)
% hObject    handle to hide7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide7


% --- Executes on button press in hide8.
function hide8_Callback(hObject, eventdata, handles)
% hObject    handle to hide8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide8


% --- Executes on button press in hide9.
function hide9_Callback(hObject, eventdata, handles)
% hObject    handle to hide9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide9


% --- Executes on button press in hide10.
function hide10_Callback(hObject, eventdata, handles)
% hObject    handle to hide10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide10


% --- Executes on button press in hide11.
function hide11_Callback(hObject, eventdata, handles)
% hObject    handle to hide11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide11


% --- Executes on button press in hide12.
function hide12_Callback(hObject, eventdata, handles)
% hObject    handle to hide12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide12


% --- Executes on button press in hide13.
function hide13_Callback(hObject, eventdata, handles)
% hObject    handle to hide13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide13


% --- Executes on button press in hide14.
function hide14_Callback(hObject, eventdata, handles)
% hObject    handle to hide14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide14

% --- Executes on button press in color12.
function color12_Callback(hObject, eventdata, handles)
% hObject    handle to color12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = uisetcolor;
set(hObject,'BackgroundColor',c);

% --- Executes on button press in setMontage.
function setMontage_Callback(hObject, eventdata, handles)
% hObject    handle to setMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channels = '{';
colors = '{';
ampChs = '{';
scaleChs = '{';
hideChs = '{';

g=0;
for e = 1:14
    
    eval(['val = get(handles.channel',num2str(e),', ''Value'');']);
    if val > 1
        eval(['channelSet = get(handles.channel',num2str(e),', ''String'');']);
        channel = channelSet(val);
        channels = [channels,'''',channel{1},''';'];

        eval(['col = get(handles.color',num2str(e),', ''BackgroundColor'');']);
        colors = [colors,'[',num2str(col),'];'];

        eval(['hide = get(handles.hide',num2str(e),', ''Value'');']);
        if hide == 1
            hideChs = [hideChs,'''',channel{1},''' '];
        end
        
        eval(['val = get(handles.scale',num2str(e),', ''Value'');']);
        eval(['scaleSet = get(handles.scale',num2str(e),', ''String'');']);
        scale = scaleSet(val);
        scaleChs = [scaleChs,'''',scale{1},''';'];
        
        eval(['amp = get(handles.amp',num2str(e),', ''Value'');']);
        if amp == 1
            g=g+1;
            ampChs = [ampChs,'''',channel{1},''' '];
            bigGridMat{g,1} = channel{1};
            eval(['bigGridMat{g,2} = handles.gridMat',num2str(e),';']);
        end
    end

end
channels = [channels,'}'];
hideChs = [hideChs,'}'];
ampChs = [ampChs,'}'];
colors = [colors,'}'];
scale =[scaleChs,'}'];

eval(['handles.montage.hideChans = ',hideChs,';']);
eval(['handles.montage.scale = flipud(',scale,');']); 
eval(['handles.montage.colors = flipud(',colors,');']);
eval(['handles.montage.electrodes = flipud(',channels,');']); 
eval(['handles.montage.scaleChans = flipud(',ampChs,');']); 

for i = 1:size(bigGridMat,1)

    % print channel index
    eval(['handles.montage.bigGridMat{',num2str(i),',1} = ''',bigGridMat{i,1},''';']);
   
    % print grid amp cells
     config = bigGridMat{i,2};
     for r = 1:size(config,1);
        eval(['handles.montage.bigGridMat{',num2str(i),',2}{',num2str(r),',1} = ''',bigGridMat{i,2}{r,1},''';']);
        eval(['handles.montage.bigGridMat{',num2str(i),',2}{',num2str(r),',2} = [',num2str(bigGridMat{i,2}{r,2}(1,1)),' ',num2str(bigGridMat{i,2}{r,2}(1,2)),' ',num2str(bigGridMat{i,2}{r,2}(1,3)),'];']);
     end
end

guidata(hObject, handles); 

uiresume(handles.figure1);



% --- Executes on button press in saveMontage.
function saveMontage_Callback(hObject, eventdata, handles)
% hObject    handle to saveMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
montageFile = sprintf('function handles = sleep_Montage(handles)\n');
montageFile = [montageFile,sprintf('%%%%    Auto-generated H�m� Scoring Montage\n')];
montageFile = [montageFile,sprintf('%%  Montage Generated from File: %s\n',handles.fileName)];
montageFile = [montageFile,sprintf('%%  Montage Generated on Date: %s\n\n',date)];
montageFile = [montageFile,sprintf('%%%%    Copyright (c) 2015 Jared M. Saletin, PhD and Stephanie M. Greer, PhD\n')];
montageFile = [montageFile,sprintf('%%\n')];
montageFile = [montageFile,sprintf('%%   This file is part of H�m�.\n')];
montageFile = [montageFile,sprintf('%%\n')];
montageFile = [montageFile,sprintf('%%   H�m� is free software: you can redistribute it and/or modify it\n')];
montageFile = [montageFile,sprintf('%%   under the terms of the GNU General Public License as published by the\n')];
montageFile = [montageFile,sprintf('%%   Free Software Foundation, either version 3 of the License, or (at your\n')];
montageFile = [montageFile,sprintf('%%   option) any later version.\n')];
montageFile = [montageFile,sprintf('%% \n')];
montageFile = [montageFile,sprintf('%%   H�m� is distributed in the hope that it will be useful, but\n')];
montageFile = [montageFile,sprintf('%%   WITHOUT ANY WARRANTY; without even the implied warranty of\n')];
montageFile = [montageFile,sprintf('%%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU\n')];
montageFile = [montageFile,sprintf('%%   General Public License for more details.\n')];
montageFile = [montageFile,sprintf('%% \n')];
montageFile = [montageFile,sprintf('%%   You should have received a copy of the GNU General Public License along\n')];
montageFile = [montageFile,sprintf('%%   with H�m�.  If not, see <http://www.gnu.org/licenses/>.\n')];
montageFile = [montageFile,sprintf('%%\n')];
montageFile = [montageFile,sprintf('%%   H�m� is intended for research purposes only. Any commerical or medical\n')];
montageFile = [montageFile,sprintf('%%   use of this software is prohibited.\n')];
montageFile = [montageFile,sprintf('%%%%\n')];


montageFile = [montageFile,sprintf('%% channels to hide\n')];
channels = '{';
colors = '{';
ampChs = '{';
scaleChs = '{';
hideChs = '{';

g=0;
for e = 1:14
    
    eval(['val = get(handles.channel',num2str(e),', ''Value'');']);
    if val > 1
        eval(['channelSet = get(handles.channel',num2str(e),', ''String'');']);
        channel = channelSet(val);
        channels = [channels,'''',channel{1},''';'];

        eval(['col = get(handles.color',num2str(e),', ''BackgroundColor'');']);
        colors = [colors,'[',num2str(col),'];'];

        eval(['hide = get(handles.hide',num2str(e),', ''Value'');']);
        if hide == 1
            hideChs = [hideChs,'''',channel{1},''' '];
        end
        
        eval(['val = get(handles.scale',num2str(e),', ''Value'');']);
        eval(['scaleSet = get(handles.scale',num2str(e),', ''String'');']);
        scale = scaleSet(val);
        scaleChs = [scaleChs,'''',scale{1},''';'];
        
        eval(['amp = get(handles.amp',num2str(e),', ''Value'');']);
        if amp == 1
            g=g+1;
            ampChs = [ampChs,'''',channel{1},''' '];
            bigGridMat{g,1} = channel{1};
            eval(['bigGridMat{g,2} = handles.gridMat',num2str(e),';']);
        end
    end

end
channels = [channels,'}'];
hideChs = [hideChs,'}'];
ampChs = [ampChs,'}'];
colors = [colors,'}'];
scaleChs =[scaleChs,'}'];

montageFile = [montageFile,sprintf('handles.hideChans = %s;\n', hideChs)];

montageFile = [montageFile,sprintf('%%electrode names that should be ploted.\n')];
montageFile = [montageFile,sprintf('handles.electrodes = flipud(%s);\n',channels)];

montageFile = [montageFile,sprintf('%%colors for each electrode. The order and length must match the electrode list\n')];
montageFile = [montageFile,sprintf('handles.colors = flipud(%s);\n', colors)];

montageFile = [montageFile,sprintf('%%scale for each electrode. The order and length must match the electrode list\n')];
montageFile = [montageFile,sprintf('handles.scale = flipud(%s);\n', scaleChs)];

montageFile = [montageFile,sprintf('%% channels to add scale lines to\n')];
montageFile = [montageFile,sprintf('handles.scaleChans = %s;\n', ampChs)];

montageFile = [montageFile,sprintf('%% voltage to place scales\n')];

for i = 1:size(bigGridMat,1)

    % print channel index
    montageFile = [montageFile,sprintf('handles.bigGridMat{%d,1} = ''%s'';\n',i,bigGridMat{i,1})];
   
    % print grid amp cells
    config = bigGridMat{i,2};
    for r = 1:size(config,1);
        montageFile = [montageFile,sprintf('handles.bigGridMat{%d,2}{%d,1} = ''%s'';\n',i,r,bigGridMat{i,2}{r,1})];
        montageFile = [montageFile,sprintf('handles.bigGridMat{%d,2}{%d,2} = [%d %d %d];\n',i,r,bigGridMat{i,2}{r,2}(1,1),bigGridMat{i,2}{r,2}(1,2),bigGridMat{i,2}{r,2}(1,3))];
    end
end
[fileName,pathName]= uiputfile({'*.m'},'Save Montage File');
fid = fopen([pathName,fileName],'w');
fwrite(fid,montageFile);
fclose(fid);

% --- Executes on button press in setGrid1.
function setGrid1_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat1 = sleepAmpGrids(handles.gridMat1);
guidata(hObject, handles);

% --- Executes on button press in setGrid2.
function setGrid2_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat2 = sleepAmpGrids(handles.gridMat2);
guidata(hObject, handles);

% --- Executes on button press in setGrid3.
function setGrid3_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat3 = sleepAmpGrids(handles.gridMat3);
guidata(hObject, handles);

% --- Executes on button press in setGrid4.
function setGrid4_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat4 = sleepAmpGrids(handles.gridMat4);
guidata(hObject, handles);

% --- Executes on button press in setGrid5.
function setGrid5_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat5 = sleepAmpGrids(handles.gridMat5);
guidata(hObject, handles);

% --- Executes on button press in setGrid6.
function setGrid6_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat6 =sleepAmpGrids(handles.gridMat6);
guidata(hObject, handles);

% --- Executes on button press in setGrid7.
function setGrid7_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat7 = sleepAmpGrids(handles.gridMat7);
guidata(hObject, handles);

% --- Executes on button press in setGrid8.
function setGrid8_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat8 = sleepAmpGrids(handles.gridMat8);
guidata(hObject, handles);

% --- Executes on button press in setGrid9.
function setGrid9_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat9 = sleepAmpGrids(handles.gridMat9);
guidata(hObject, handles);

% --- Executes on button press in setGrid10.
function setGrid10_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat10 = sleepAmpGrids(handles.gridMat10);
guidata(hObject, handles);

% --- Executes on button press in setGrid11.
function setGrid11_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat11 = sleepAmpGrids(handles.gridMat11);
guidata(hObject, handles);

% --- Executes on button press in setGrid12.
function setGrid12_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat12 = sleepAmpGrids(handles.gridMat12);
guidata(hObject, handles);

% --- Executes on button press in setGrid13.
function setGrid13_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat13 = sleepAmpGrids(handles.gridMat13);
guidata(hObject, handles);

% --- Executes on button press in setGrid14.
function setGrid14_Callback(hObject, eventdata, handles)
% hObject    handle to setGrid14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gridMat14 = sleepAmpGrids(handles.gridMat14);
guidata(hObject, handles);

% --- Executes on selection change in scale1.
function scale1_Callback(hObject, eventdata, handles)
% hObject    handle to scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale1


% --- Executes during object creation, after setting all properties.
function scale1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale2.
function scale2_Callback(hObject, eventdata, handles)
% hObject    handle to scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale2


% --- Executes during object creation, after setting all properties.
function scale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale3.
function scale3_Callback(hObject, eventdata, handles)
% hObject    handle to scale3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale3


% --- Executes during object creation, after setting all properties.
function scale3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale4.
function scale4_Callback(hObject, eventdata, handles)
% hObject    handle to scale4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale4


% --- Executes during object creation, after setting all properties.
function scale4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale5.
function scale5_Callback(hObject, eventdata, handles)
% hObject    handle to scale5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale5


% --- Executes during object creation, after setting all properties.
function scale5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in scale6.
function scale6_Callback(hObject, eventdata, handles)
% hObject    handle to scale6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale6


% --- Executes during object creation, after setting all properties.
function scale6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale7.
function scale7_Callback(hObject, eventdata, handles)
% hObject    handle to scale7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale7


% --- Executes during object creation, after setting all properties.
function scale7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale8.
function scale8_Callback(hObject, eventdata, handles)
% hObject    handle to scale8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale8


% --- Executes during object creation, after setting all properties.
function scale8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale9.
function scale9_Callback(hObject, eventdata, handles)
% hObject    handle to scale9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale9


% --- Executes during object creation, after setting all properties.
function scale9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale10.
function scale10_Callback(hObject, eventdata, handles)
% hObject    handle to scale10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale10


% --- Executes during object creation, after setting all properties.
function scale10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale11.
function scale11_Callback(hObject, eventdata, handles)
% hObject    handle to scale11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale11


% --- Executes during object creation, after setting all properties.
function scale11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale12.
function scale12_Callback(hObject, eventdata, handles)
% hObject    handle to scale12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale12


% --- Executes during object creation, after setting all properties.
function scale12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale13.
function scale13_Callback(hObject, eventdata, handles)
% hObject    handle to scale13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale13


% --- Executes during object creation, after setting all properties.
function scale13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scale14.
function scale14_Callback(hObject, eventdata, handles)
% hObject    handle to scale14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scale14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale14


% --- Executes during object creation, after setting all properties.
function scale14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);
%delete(hObject);