function varargout = GUI_Messenger(varargin)
%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      Φεβρουάριος 2015
%
%      Αρχείο GUI_Messenger_RS232.m
%
%      Δημιουργεί δεδομένα μεταβλητού μήκους αξιοποιώντας το κείμενο που πληκτρολογείται στο Transmit Terminal.
%      Τα δεδομένα στέλνονται στη σειριακή θύρα όταν πατηθεί το Send.
%      Αν υπάρχουν δεδομένα εισόδου στη σειριακή θύρα, αυτά εκτυπώνονται στο Receive Terminal όταν πατηθεί το Receive.
%      Τα πλήκτρα Send, Receive, activate και Deactivate  ενημερώνουν και
%      για την κατάσταση των RTS/CTS σημάτων
%
%      Χρησιμοποιεί την ίδια σειριακή θύρα για μετάδοση και για λήψη δεδομένων.
%      Η σειριακή θύρα ενεργοποιείται με την έναρξη του προγράμματος.
%      Πριν τον τερματισμό του προγράμματος, πρέπει να απενεργοποιηθεί η σειριακή θύρα πατώντας το 'De-activate the RS232 port'.
%
%      Στο Command Window  περιοδικά δίνονται πληροφορίες για την κατάσταση του συστήματος
%


%GUI_Messenger M-file for GUI_Messenger.fig
%      GUI_Messenger, by itself, creates a new GUI_Messenger or raises the existing
%      singleton*.
%
%      H = GUI_Messenger returns the handle to a new GUI_Messenger or the handle to
%      the existing singleton*.
%
%      GUI_Messenger('Property','Value',...) creates a new GUI_Messenger using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GUI_Messenger_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_Messenger('CALLBACK') and GUI_Messenger('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_Messenger.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Messenger

% Last Modified by GUIDE v2.5 07-Jan-2012 11:52:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Messenger_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Messenger_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before GUI_Messenger is made visible.
function GUI_Messenger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
global sport
global TxData
global RxData
global DD

clc;
disp('GUI_Messenger is starting up ....');
% Choose default command line output for GUI_Messenger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

TxData = [];
set (handles.editTx,'String', TxData);
RxData = [];
set (handles.editRx,'String', RxData);
DD = [];
set (handles.editRx,'String', DD);

sport = serial('COM51', 'BaudRate', 9600, 'Parity','none', 'Terminator', '');
set(sport, 'FlowControl', 'none');
set(sport, 'InputBufferSize', 1024);
set(sport, 'OutputBufferSize', 1024);
fopen(sport)
disp('  Serial port has been activated.');

    sport.DataTerminalReady = 'on';             % Assert DTR
    DD = 'ON';                           
    set (handles.edit7,'String',char(DD),'ForegroundColor', 'g');
    pause(1);
    arv = sport.PinStatus.DataSetReady;         % Check DSR
    if length(arv) == 2                       
        set (handles.edit8,'BackgroundColor', 'g');
    else
        set (handles.edit8,'BackgroundColor', 'r');
    end


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Messenger_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function editTx_Callback(hObject, eventdata, handles)
% hObject    handle to editTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of editTx as text
%        str2double(get(hObject,'String')) returns contents of editTx as a double
global TxData
global sport
s1 = get(hObject,'String');
TxData = s1;
arv = sport.PinStatus.DataSetReady;         % Check DSR
if length(arv) == 2                       
    set (handles.edit8,'BackgroundColor', 'g');
else
    set (handles.edit8,'BackgroundColor', 'r');
end



% --- Executes during object creation, after setting all properties.
function editTx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonSend.
function pushbuttonSend_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TxData
global sport

arv = sport.PinStatus.DataSetReady;         % Check DSR
if length(arv) == 2                       % wait until available
    set (handles.edit8,'BackgroundColor', 'g');
    [m,n] = size(TxData);
    if m*n ~= 0
        if n < 64 && m*n > 64                             %  Truncate to 64 bytes
            m = floor(64/(n+1));
        elseif n >= 64
            TxData = TxData(1,1:63);
        end
        for i=1:m
            fwrite(sport, [TxData(i,:) 13], 'uchar');        %  Transmit a packet
             data2tx = sport.BytesToOutput;
              while data2tx > 0
                  data2tx = sport.BytesToOutput;
              end
            pause(1);
        end
            TxData = [];
            set (handles.editTx,'String', TxData);
    end
else
    set (handles.edit8,'BackgroundColor', 'r');
            pause(.5);                               
    set (handles.edit8,'BackgroundColor', 'k');
            pause(1);                               
    set (handles.edit8,'BackgroundColor', 'r');
end


function editRx_Callback(hObject, eventdata, handles)
% hObject    handle to editRx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRx as text
%        str2double(get(hObject,'String')) returns contents of editRx as a double


% --- Executes during object creation, after setting all properties.
function editRx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonReceive.
function pushbuttonReceive_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReceive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global RxData
global sport
global DD

    arv = sport.PinStatus.ClearToSend;         % Check CTS
    if length(arv) == 2                       
        set (handles.edit8,'BackgroundColor', 'g');
    else
        set (handles.edit8,'BackgroundColor', 'r');
    end
    if length(arv) == 2
    	lenba = sport.BytesAvailable;
        if lenba ~= 0                                    %  Are there data to receive?
            tmp = fread(sport, lenba)';
            RxData = tmp;                               %  display all received characters
            set (handles.editRx,'String',char(RxData));
        else
            RxData = [];
            set (handles.editRx,'String',char(RxData));
        end
    else
            DD = 'OFF';                               
            set (handles.edit7,'String',char(DD),'ForegroundColor', 'k');
            RxData = [];
            set (handles.editRx,'String',char(RxData));
            pause(.5);                               
            set (handles.edit7,'String',char(DD),'ForegroundColor', 'r');
            pause(.3);                               
            set (handles.edit7,'String',char(DD),'ForegroundColor', 'k');
            pause(.5);                               
            set (handles.edit7,'String',char(DD),'ForegroundColor', 'r');
    end


% --- Executes on button press in EXITbutton.
function EXITbutton_Callback(hObject, eventdata, handles)
% hObject    handle to EXITbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sport
        fclose(sport);
        clear sport;
        disp(' ');
        disp('  Serial port has been deactivated.');


% --- Executes on button press in pushbutton12.
function Enablepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sport
global DD
    sport.RequestToSend = 'on';                 % Assert RTS
    DD = 'ON';                             
    set (handles.edit7,'String',char(DD),'ForegroundColor', 'g');
    pause(0.5);
    arv = sport.PinStatus.ClearToSend;         % Check CTS
    if length(arv) == 2                       
        set (handles.edit8,'BackgroundColor', 'g');
    else
        set (handles.edit8,'BackgroundColor', 'r');
    end

% --- Executes on button press in pushbutton13.
function Disablepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sport
global DD
    sport.RequestToSend = 'off';                 % Deassert RTS
    DD = 'OFF';                              
    set (handles.edit7,'String',char(DD),'ForegroundColor', 'r');
    pause(0.5);
    arv = sport.PinStatus.ClearToSend;         % Check CTS
    if length(arv) == 2                       
        set (handles.edit8,'BackgroundColor', 'g');
    else
        set (handles.edit8,'BackgroundColor', 'r');
    end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


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
