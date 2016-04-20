%%
%      ������������ ������������� ���������
%      
%      ��������� 2015
%
%      ������ Channel_Character_Prob.m
%
%      �������� ���������� ��� �� COM-x ��� ���� ������� ���� ��� COM-y, 
%      �� ���������� ��������� �� �������� ������� ����������. 
%      �� ���� ��������� ���� �������� ����������.
%
%      ��� �� ������� ��� ��������� ���  ������������, �������    Cntrl-C    
%      ��� ���� ������ �� ���������� � ������� ���� ��  %%    End of Session
%
close all;
clear all;
clc;

 disp('-------------CCE---------------!');
 disp('   Character Channel Emulator   ');
 
 Cstart = 128;          % ������ ���� �������� ����������
 Cend = 255;            % ������ ���� �������� ����������
 eprob = 0.25;          % ���������� ���������

 %   Serial Ports Initialization
 disp('Serial ports initialization.....');
 rs_rate = 9600;
 RxBufferSize = 32768;
 TxBufferSize = 32768;
 
 sport_A = serial('COM48', 'BaudRate', rs_rate, 'Parity','none', 'Terminator', '','InputBufferSize', RxBufferSize,'OutputBufferSize', TxBufferSize);
 fopen(sport_A)
 
 sport_B = serial('COM34', 'BaudRate', rs_rate, 'Parity','none', 'Terminator', '','InputBufferSize', RxBufferSize,'OutputBufferSize', TxBufferSize);
 fopen(sport_B)
     
    
 while(1)
     % B-A
     len = sport_B.BytesAvailable;
     if len > 0
         Char2F = fread(sport_B,1);
         if Char2F >= Cstart && Char2F <= Cend && rand <= eprob
             Char2F = mod(Char2F + randi(256), 256);
         end
         fwrite(sport_A, Char2F, 'uchar');
     end
     
     % A-B
     len = sport_A.BytesAvailable;
     if len > 0
         Char2F = fread(sport_A,1);
         if Char2F >= Cstart && Char2F <= Cend && rand <= eprob
             Char2F = mod(Char2F + randi(256), 256);
         end
         fwrite(sport_B, Char2F, 'uchar');
     end
 end


%%    End of Session
disp('Closing Serial ports .....');
fclose(sport_B)
clear sport_B
fclose(sport_A)
clear sport_A

disp('End of Session');
