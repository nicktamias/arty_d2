%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%
%      Φεβρουάριος 2015
%
%      Αρχείο Gen_Sink_RS232_noHFC_2P.m
%
%       Πρόγραμμα δημιουργίας, αποθήκευσης και ελέγχου χαρακτήρων μέσω δύο
%       RS232 port  χωρίς έλεγχο ροής.  
%       Οι χαρακτήρες που μεταδίδονται αποθηκεύονται στα arrays  TxChars_A και TxChars_Β.
%       Oι χαρακτήρες που λαμβάνονται αποθηκεύονται στα arrays  RxChars_A και RxChars_Β.
%
%       Στο Command Window  περιοδικά δίνονται πληροφορίες για την κατάσταση  του συστήματος
%       Στο τέλος δίνεται το ποσοστό λάθους και ο συνολικός χρόνος/ρυθμός μετάδοσης.
%
%       Για τη διακοπή της εκτέλεσης του  προγράμματος, πατήστε    Ctrl-C
%       και μετα πρέπει να εκτελεστεί η  εντολή  fclose(s1); clear s1;  στο Command Window .
%
%
clear all;
close all;
clc;

disp('Starting the Characters Gen/Sink Application . . . . ');

Nc = 300;           %  Πλήθος χαρακτηρων προς μετάδοση/λήψη
Nstart = 0;         %  Περιοχή τιμων χαρακτήρων προς μετάδοση
Nend = 255;

disptime = 2;       %  χρονος ενημερωσης (secs)
Nbuffer = 2*Nc;      % Tx/Rx buffer length

TxChars_A = uint8(randi([Nstart Nend], 1, Nc));
RxChars_A = uint8(zeros(1, Nc));
TxChars_B = uint8(randi([Nstart Nend], 1, Nc));
RxChars_B = uint8(zeros(1, Nc));

%%
disp('Opening the 1st RS232 port . . . . . ');
s1 = serial('COM51','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
% s1.RecordDetail = 'verbose';
% s1.RecordName = 'S1.txt';
% record(s1,'on')
disp('RS232 port activated');
disp(' ');

disp('Opening the 2nd RS232 port . . . . . ');
s2 = serial('COM57','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s2, 'FlowControl', 'none');
set(s2, 'InputBufferSize', Nbuffer);
set(s2, 'OutputBufferSize', Nbuffer);
fopen(s2)
% s2.RecordDetail = 'verbose';
% s2.RecordName = 'S2.txt';
% record(s2,'on')
disp('RS232 port activated');
disp(' ');


%%
tstart = clock;
tinit = tstart;

cnt_t_A = 0;
cnt_r_A = 0;
cnt_t_B = 0;
cnt_r_B = 0;
while cnt_t_A < Nc || cnt_r_A < Nc || cnt_t_B < Nc || cnt_r_B < Nc
    if s1.BytesToOutput < Nbuffer && cnt_t_A < Nc
        cnt_t_A = cnt_t_A + 1;          % generate new character
        fwrite(s1,TxChars_A(cnt_t_A));
    end
    
    len = s2.BytesAvailable;    % wait to receive a new character
    if len ~= 0
        cnt_r_A = cnt_r_A + 1;
        RxChars_A(cnt_r_A) = fread(s2,1);
    end
    
    if s2.BytesToOutput < Nbuffer && cnt_t_B < Nc
        cnt_t_B = cnt_t_B + 1;          % generate new character
        fwrite(s2,TxChars_B(cnt_t_B));
    end
    
    len = s1.BytesAvailable;    % wait to receive a new character
    if len ~= 0
        cnt_r_B = cnt_r_B + 1;
        RxChars_B(cnt_r_B) = fread(s1,1);
    end
        
    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  Outgoing Characters A->B: %d  of %d  ', cnt_t_A, Nc);
        fprintf('\n  Incoming Characters B->A: %d  of %d \n', cnt_r_A, Nc);
        fprintf('\n  Outgoing Characters B->A: %d  of %d  ', cnt_t_B, Nc);
        fprintf('\n  Incoming Characters A->B: %d  of %d \n', cnt_r_B, Nc);
        tstart = clock;
    end

end

timedif = etime(clock, tinit);      %  Total time

%%
disp(' ');
disp('Closing the RS232 ports . . . . . ');
% record(s1,'off')
fclose(s1)
delete(s1)
clear s1
% record(s2,'off')
fclose(s2)
delete(s2)
clear s2
disp('RS232 ports deactivated');

disp(' ');
if sum(TxChars_A == RxChars_A)==Nc && sum(TxChars_B == RxChars_B)==Nc
    disp('Correct Data Transmission');
else
    disp('Incorrect Data Transmission');
    fprintf('\nCharacter Error Ratio A->B =  %6.5f', sum(TxChars_A ~= RxChars_A)/Nc);
    fprintf('\nCharacter Error Ratio B->A =  %6.5f', sum(TxChars_B ~= RxChars_B)/Nc);
end

fprintf('\nCharacters exchanged: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Nc, timedif, Nc/timedif);

disp(' . . . .  Ending the Two-ways Gen/Sink Application.');
