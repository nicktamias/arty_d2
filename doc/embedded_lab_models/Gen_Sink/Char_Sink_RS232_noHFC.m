%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%      Φεβρουάριος 2015
%
%      Αρχείο Char_Sink_RS232_noHFC.m
%
%       Πρόγραμμα αποθήκευσης χαρακτήρων μέσω RS232 port χωρις έλεγχο ροής.
%       Oι χαρακτήρες που λαμβάνονται αποθηκεύονται στο array  RxChars.
%
%       Στο Command Window  περιοδικά δίνονται πληροφορίες για την κατάσταση  του συστήματος
%
%       Για τη διακοπή της εκτέλεσης του  προγράμματος, πατήστε    Ctrl-C    
%       και μετα πρέπει να εκτελεστεί η  εντολή  fclose(s1); clear s1;  στο Command Window .
%
%
clear all;
close all;
clc;

disp('Starting the Characters Sink Application . . . . ');

Nc = 100;           %  Πλήθος χαρακτηρων προς λήψη

disptime = 2;       %  χρονος ενημερωσης (secs)
Nbuffer = 2*Nc;     %  Τx/Rx buffer length

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
while cnt < Nc
    len = s1.BytesAvailable;    % wait to receive a new character
    if len ~= 0
        cnt = cnt + 1;          % receive new character
        out= fread(s1,1);
        RxChars(cnt) = out;
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
