%%
%      ������������ ������������� ���������
%
%      ����������� 2015
%
%      ������ GenSink_RS232_noHFC_1P.m
%
%       ��������� �����������, ����������� ��� ������� ���������� ���� RS232 port 
%       ����� ������ ����.  
%       �� ���������� ��� ������������ ������������� ��� array  TxChars.
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

disp('Starting the Characters Gen/Sink Application . . . . ');

Nc = 100;           %  ������ ���������� ���� ��������/����
Nstart = 0;         %  ������� ����� ���������� ���� ��������
Nend = 255;

disptime = 2;       %  ������ ���������� (secs)
Nbuffer = 2*Nc;      % Tx/Rx buffer length

TxChars = uint8(randi([Nstart Nend], 1, Nc));
RxChars = uint8(zeros(1, Nc));

%%
disp('Opening the RS232 port . . . . . ');
s1 = serial('COM56','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
% s1.RecordDetail = 'verbose';
% s1.RecordName = 'S1.txt';
% record(s1,'on')
disp('RS232 port activated');
disp(' ');


%%
tstart = clock;
tinit = tstart;

cnt_t = 0;
cnt_r = 0;
while cnt_t < Nc || cnt_r < Nc
    if s1.BytesToOutput < Nbuffer && cnt_t < Nc
        cnt_t = cnt_t + 1;          % generate new character
        fwrite(s1,TxChars(cnt_t));
    end
    
    len = s1.BytesAvailable;    % wait to receive a new character
        if len ~= 0
            cnt_r = cnt_r + 1; 
            RxChars(cnt_r) = fread(s1,1);
        end

    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  Outgoing Characters: %d  of %d  ', cnt_t, Nc);
        fprintf('\n  Incoming Characters: %d  of %d \n', cnt_r, Nc);
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
if TxChars == RxChars
    disp('Correct Data Transmission');
else
    disp('Incorrect Data Transmission');
    fprintf('\nCharacter Error Ratio =  %6.5f', sum(TxChars ~= RxChars)/Nc);
end

fprintf('\nCharacters exchanged: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Nc, timedif, Nc/timedif);

disp(' . . . .  Ending the Characters Gen/Sink Application.');
