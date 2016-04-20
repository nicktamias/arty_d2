%%
%      ������������ ������������� ���������
%      
%      ����������� 2015
%
%      ������ CharSink_RS232_HFC.m
%
%       ��������� ����������� ���������� ���� RS232 port �� ������ ����.
%       � ���������� ����� ������������ ����������������.
%       O� ���������� ��� ����������� ������������� ��� array  RxChars.
%
%       ��� Command Window  ��������� �������� ����������� ��� ��� ���������  ��� ����������
%       ��� ����� ������� �� ������� ������ ��� � ��������� ������/������ ���������.
%
%       ��� �� ������� ��� ��������� ���  ������������, �������    Ctrl-C    
%       ��� ���� ������ �� ���������� �  ������  fclose(s1); clear s1;  ��� Command Window .
%
%
clear all;
close all;
clc;

disp('Starting the Characters Sink Application . . . . ');

Nc = 100;           %  ������ ���������� ���� ����
pr_off = 0.05;       %  ���������� ��������������� �����

disptime = 2;       %  ������ ���������� (secs)
Nbuffer = 256;      %  �x/Rx buffer length

RxChars = uint8(zeros(1, Nc));

%%
disp('Opening the RS232 port . . . . . ');
s1 = serial('COM56','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
s1.RecordDetail = 'verbose';
s1.RecordName = 'S_sink.txt';
record(s1,'on')
disp('RS232 port activated');
disp(' ');


%%
tstart = clock; 
tinit = tstart;

cnt = 0;
s1.RequestToSend = 'on';         %  Enable RTS (Rx ON)
while cnt < Nc
    len = s1.BytesAvailable;    % wait to receive a new character
    if len ~= 0
        cnt = cnt + 1;          % receive new character
        out= fread(s1,1);
        RxChars(cnt) = out;
    end

    %  Deactivate for 1 sec the receiver with probability pr_off
    deactpr = rand(1,1);
    if deactpr <= pr_off
        s1.RequestToSend = 'off';        %  Disable RTS (Rx OFF)
        disp('OFF'); pause(1); disp('ON');
        s1.RequestToSend = 'on';         %  Enable RTS (Rx ON)
    end
    
    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  Incoming Characters: %d  of %d \n', cnt, Nc);
        tstart = clock;
    end
end


timedif = etime(clock, tinit);      %  Total time


%%
disp(' ');
disp('Closing the RS232 port . . . . . ');
record(s1,'off')
fclose(s1)
delete(s1)
clear s1

disp('RS232 port deactivated');
disp(' ');

fprintf('\nCharacters received: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Nc, timedif, Nc/timedif);

disp(' . . . .  Ending the Characters Sink Application.');
