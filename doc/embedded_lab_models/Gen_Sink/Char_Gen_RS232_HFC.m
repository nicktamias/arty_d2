%%
%      ������������ ������������� ���������
%
%      ����������� 2015
%
%      ������ Char_Gen_RS232_HFC.m
%
%       ��������� ����������� ��� ��������� ���������� ���� RS232 port �� ������ ����.
%       �� ���������� ��� ������������ ������������� ��� array  TxChars.
%
%       ��� Command Window  ��������� �������� ����������� ��� ��� ���������  ��� ����������
%       ��� ����� ������� � ��������� ������/������ ���������.
%
%       ��� �� ������� ��� ��������� ���  ������������, �������    Ctrl-C
%       ��� ���� ������ �� ���������� �  ������  fclose(s1); clear s1;  ��� Command Window .
%
clear all;
close all;
clc;

disp('Starting the Characters Generator Application . . . . ');

Nc = 100;           %  ������ ���������� ���� ��������
Nstart = 0;       %  ������� ����� ���������� ���� ��������
Nend = 255;
disptime = 2;      %  ������ ���������� (secs)
Nbuffer = 1;      % Tx/Rx buffer length

pdelay = 0.0;       % ��������� ������ ������ ���������� ����������  [sec]

TxChars = uint8(randi([Nstart Nend], 1, Nc));

%%
disp('Opening the RS232 port . . . . . ');
s1 = serial('COM34','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
if pdelay ~= 0
    s1.RecordDetail = 'verbose';
    s1.RecordName = 'S_gen.txt';
    record(s1,'on')
end
disp('RS232 port activated');
disp(' ');


%%
tstart = clock;
tinit = tstart;

cnt = 0;
err = 0;
while cnt < Nc
    arv = s1.PinStatus.ClearToSend;      %  Check if Sink is ON,
    if length(arv) == 2  && s1.BytesToOutput <= Nbuffer-1
        cnt = cnt + 1;          
        fwrite(s1,TxChars(cnt));
        pause(pdelay);
    end
    
    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  Outgoing Characters: %d  of %d \n', cnt, Nc);
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

fprintf('\nCharacters transmitted: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Nc, timedif, Nc/timedif);

disp(' . . . .  Ending the Characters Generator Application.');
