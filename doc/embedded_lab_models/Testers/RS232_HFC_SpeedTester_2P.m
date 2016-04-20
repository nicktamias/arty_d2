%%
%  Ενσωματωμένα Επικοινωνιακά Συστήματα
%
%   Δεκέμβριος 2015
%
%   Αρχείο RS232_HFC_SpeedTester_2P.m
%
%   RS232 communications Speed Tester  (RS232 uses HFC)
%   Μετάδοση χαρακτήρων από το ένα RS232 port και λήψη από το άλλο.
%   Ροή δεδομένων μόνο στην μια κατεύθυνση (configuration #3)
%
clear all;
close all;
clc;

%%
disp('Opening the RS232 ports . . . . . ');
s1 = serial('COM34','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', 1);
set(s1, 'OutputBufferSize', 1);
fopen(s1)
s2 = serial('COM57','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s2, 'FlowControl', 'none');
set(s2, 'InputBufferSize', 1);
set(s2, 'OutputBufferSize', 1);
fopen(s2)
disp('RS232 ports activated');
disp(' ');
s1.RequestToSend = 'on';         %  Rx ON
s2.RequestToSend = 'on'; 

%%

disp('Transmission Speed Tester');

Ns = 1024;              % No of characters to transmit
Cmin = 0;               % minimum character value
Cmax = 255;             % maximum character value

data_out = uint8(randi([Cmin Cmax], 1, Ns));
data_in = zeros(1,Ns);

tx_cnt = 0;
rx_cnt = 0;
ts = tic;
while (tx_cnt < Ns || rx_cnt < Ns)
    if (tx_cnt < Ns) && (length(s1.PinStatus.ClearToSend) == 2) ...
            && (s1.BytesToOutput == 0)   % CTS = 1
        tx_cnt = tx_cnt+ 1;
        fwrite(s1, data_out(tx_cnt), 'uchar');  
    end
    if rx_cnt < Ns
        b2r = s2.BytesAvailable;
        if b2r > 0
            data_in(rx_cnt + 1:rx_cnt + b2r) = fread(s2,b2r);
            rx_cnt = rx_cnt + b2r;
        end
    end
end
time_elapsed = toc(ts);

%%
disp(' ');
disp('Closing the RS232 ports . . . . . ');
fclose(s1)
delete(s1)
clear s1
fclose(s2)
delete(s2)
clear s2
disp('RS232 ports deactivated');

disp(' ');


%%
if data_out == data_in
    disp('Data Exchanged Correctly!')
    fprintf('\nData Rate = %4.2f bytes/sec\n\n', Ns/time_elapsed);
else
    ch_e = (data_out-data_in)~=0;
    disp('Error During Data Exchange!!!!')
    fprintf('\nProbability of error = %5.4f\n', sum(ch_e)/Ns);
    subplot(2,1,1);
    plot(data_in,'ok'); hold on; plot(data_out,'ob');  plot(abs(data_out - data_in), '*r');
    subplot(2,1,2);
    plot(ch_e);
end
