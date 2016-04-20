%%
%  Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%   Φεβρουάριος 2015
%
%   Αρχείο RS232_noHFC_LB_1P.m
%
%   RS232 loop-back - no HFC 
%
close all;
clear all;
clc;

%%
LB = 128;      % Tx/Rx buffer length
disp('Opening the RS232 port . . . . . ');
sport = serial('COM34','BaudRate',9600,'Parity','even', 'Terminator', '');
set(sport, 'FlowControl', 'none');
set(sport, 'InputBufferSize', LB);
set(sport, 'OutputBufferSize', LB);
fopen(sport)
disp('RS232 port activated');

%%
while (1)
    if sport.BytesToOutput < LB
        b2r = sport.BytesAvailable;
        if b2r > 0
            data_val = fread(sport,1);
            fwrite(sport, data_val, 'uchar');
        end
    end
end


%% Disconnect the RS232 object from the host. 
% 
disp('Closing the RS232 port . . . . . ');
fclose(sport)
delete(sport)
clear sport

disp('RS232 port deactivated');
