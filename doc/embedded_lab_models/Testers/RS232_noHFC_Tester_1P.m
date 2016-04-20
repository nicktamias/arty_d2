%%
%  Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%   Φεβρουάριος 2015
%
%   Αρχείο RS232_noHFC_Tester_1P.m
%
%   Single RS232 port Tester
%
clear all;
close all;
clc;

Ns = 256;               % Αριθμός χαρακτήρων
pdelay = 0.5;          % Ελάχιστος χρόνος μεταξύ διαδοχικών χαρακτήρων  [sec]
ch_out = zeros(1,Ns);
ch_in = zeros(1,Ns);
Nbuffer = 2*Ns;      %  Τx/Rx buffer length


disp('Opening the RS232 port . . . . . ');
s = serial('COM26','BaudRate',38400,'Parity','even', 'Terminator', '');
set(s, 'FlowControl', 'none');
set(s, 'InputBufferSize', Nbuffer);
set(s, 'OutputBufferSize', Nbuffer);
fopen(s)
s.RecordDetail = 'verbose';
s.RecordName = 'S_gen.txt';
record(s,'on')
disp('RS232 port activated');
disp(' ');



%%
for m=1:Ns
        ch_out(m) = uint8(m-1);
        fwrite(s, ch_out(m), 'uchar');
        pause(pdelay);
        len = s.BytesAvailable;
        if len > 0
            ch_in(m) = fread(s,1);
            fprintf('%c', ch_in(m));
        end
end
fprintf('\n\n');

if ch_out == ch_in
    disp('Local Port: OK!')
else
    disp('Local Port: Error!')
    len = s.BytesAvailable;
    out = [];
    for m=1:len
        out = [out fread(s,1)];
    end
    fprintf('%d', out);
end


%%
disp('Closing the RS232 port . . . . . ');
fclose(s)
delete(s)
clear s
disp('RS232 port deactivated');
disp(' ');
