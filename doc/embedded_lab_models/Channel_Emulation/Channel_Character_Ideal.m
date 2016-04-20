%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%      Νοέμβριος 2015
%
%      Αρχείο Channel_Character_Ideal.m
%
%      Λαμβάνει χαρακτήρες από το COM-x και τους στέλνει ξανά στο COM-y, 
%      χωρίς να προστεθεί θόρυβος. Το ίδιο συμβαίνει στην αντίθετη κατεύθυνση.
%
%      Για τη διακοπή της εκτέλεσης του  προγράμματος, πατήστε    Cntrl-C    
%      και μετα πρέπει να εκτελεστεί ο κώδικας μετά το  %%    End of Session
%
close all;
clear all;
clc;

 disp('-------------ICCE---------------!');
 disp('Ideal Character Channel Emulator!');

 %   Serial Ports Initialization
 disp('Serial ports initialization.....');
 rs_rate = 9600;
 RxBufferSize = 131072;
 TxBufferSize = 131072;
 
 sport_A = serial('COM34', 'BaudRate', rs_rate, 'Parity','none', 'Terminator', '','InputBufferSize', RxBufferSize,'OutputBufferSize', TxBufferSize);
 fopen(sport_A)
 
 sport_B = serial('COM48', 'BaudRate', rs_rate, 'Parity','none', 'Terminator', '','InputBufferSize', RxBufferSize,'OutputBufferSize', TxBufferSize);
 fopen(sport_B)
     
    
 while(1)
     % B-A
     len = sport_B.BytesAvailable;
     if len > 0
         Char2F = fread(sport_B,1);
         fwrite(sport_A, Char2F, 'uchar');
     end
     
     % A-B
     len = sport_A.BytesAvailable;
     if len > 0
         Char2F = fread(sport_A,1);
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
