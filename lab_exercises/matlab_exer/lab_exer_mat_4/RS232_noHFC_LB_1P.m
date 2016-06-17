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
LB = 1;      % Tx/Rx buffer length
lb_cnt = 0;
disp('Opening the RS232 port . . . . . ');
sport = serial('COM12','BaudRate',38400,'Parity','none', 'Terminator', '');
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
            lb_cnt = lb_cnt + 1;
            fprintf('%d: %d\n', lb_cnt, data_val);
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
