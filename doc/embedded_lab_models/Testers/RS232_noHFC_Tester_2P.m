%%
%  Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%   Φεβρουάριος 2015
%
%   Αρχείο RS232_noHFC_Tester_2P.m
%
%   Two RS232 Ports Tester
%
clear all;
close all;
clc;

%%
disp('Opening the RS232 ports . . . . . ');
s1 = serial('COM26','BaudRate',57600,'Parity','even', 'Terminator', '');
fopen(s1)
s2 = serial('COM35','BaudRate',57600,'Parity','even', 'Terminator', '');
fopen(s2)
disp('RS232 ports activated');
disp(' ');

out = [];
in = [];

%%

for i=1:255
        in = [in uint8(i)];
        fwrite(s1, in(i), 'uchar');
        
        len = s2.BytesAvailable;
        for m=1:len
            out = [out fread(s2,1)];
        end
        fprintf('%d\n', out);
end

        pause(1);           %  wait to complete Tx
        len = s2.BytesAvailable;
        for m=1:len
            out = [out fread(s2,1)];
        end


%%
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
if in == out
    disp('Transmission status: OK');
else
    disp('Transmission status: Error!');
end

disp(' ');
