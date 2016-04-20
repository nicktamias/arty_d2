%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%
%      Φεβρουάριος 2015
%
%      Αρχείο GenSink_RS232_HFC_2P.m
%
%       Πρόγραμμα δημιουργίας, αποθήκευσης και ελέγχου χαρακτήρων μέσω 2 RS232 ports 
%       με έλεγχο ροής.  Η δυνατότητα λήψης περιστασιακά απενεργοποιείται.
%       Οι χαρακτήρες που μεταδίδονται αποθηκεύονται στα TxΑ και TxB.
%       Oι χαρακτήρες που λαμβάνονται αποθηκεύονται στο  RxA και RxB.
%
%       Στο Command Window  περιοδικά δίνονται πληροφορίες για την κατάσταση  του συστήματος
%       Στο τέλος δίνεται το ποσοστό λάθους και ο συνολικός χρόνος/ρυθμός μετάδοσης.
%
%       Για τη διακοπή της εκτέλεσης του  προγράμματος, πατήστε    Ctrl-C
%       και μετα πρέπει να εκτελεστεί η  εντολή  fclose(s1); clear s1;  ...
%       fclose(s2); clear s2; στο Command Window .
%
%
clear all;
close all;
clc;

disp('Starting the Characters Gen/Sink Application . . . . ');

Ns = 100;           %  Πλήθος χαρακτηρων προς μετάδοση/λήψη
Nstart = 0;         %  Περιοχή τιμων χαρακτήρων προς μετάδοση
Nend = 255;
pr_off = 0.1;       %  Πιθανότητα απενεργοποίησης δέκτη

disptime = 2;       %  χρονος ενημερωσης (secs)
Nbuffer = 1;      % Tx/Rx buffer length

Tx_A = uint8(randi([Nstart Nend], 1, Ns));
Rx_A = uint8(zeros(1, Ns));
Tx_B = uint8(randi([Nstart Nend], 1, Ns));
Rx_B = uint8(zeros(1, Ns));

%%
disp('Opening the RS232 ports . . . . . ');
s1 = serial('COM34','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
s1.RecordDetail = 'verbose';
s1.RecordName = 'S1.txt';
record(s1,'on')
s2 = serial('COM57','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s2, 'FlowControl', 'none');
set(s2, 'InputBufferSize', Nbuffer);
set(s2, 'OutputBufferSize', Nbuffer);
fopen(s2)
s2.RecordDetail = 'verbose';
s2.RecordName = 'S2.txt';
record(s2,'on')
disp('RS232 ports activated');
disp(' ');
s1.RequestToSend = 'on';         %  Enable RTS (Rx ON)
s2.RequestToSend = 'on'; 


%%
tstart = clock;
tinit = tstart;

cnta_t = 0;
cnta_r = 0;
cntb_t = 0;
cntb_r = 0;
s1.RequestToSend = 'on';
s2.RequestToSend = 'on';

while cnta_t < Ns || cnta_r < Ns ||cntb_t < Ns || cntb_r < Ns
    %   A->B
    arv = s1.PinStatus.ClearToSend;      %  Check if Sink is ON  and the output buffer empty
    if length(arv) == 2  && s1.BytesToOutput < Nbuffer && cnta_t < Ns
        cnta_t = cnta_t + 1;          % generate new character
        fwrite(s1,Tx_A(cnta_t));
    end
    
    %  Deactivate or activate the receiver
    deactpr = rand(1,1);
    if deactpr <= pr_off
        s1.RequestToSend = 'off';        %  Disable RTS (Rx OFF)
    else
        s1.RequestToSend = 'on';         %  Enable RTS (Rx ON)
        len = s1.BytesAvailable;    % wait to receive a new character
        if len ~= 0
            cnta_r = cnta_r + 1; 
            Rx_A(cnta_r) = fread(s1,1);
        end
    end 

    
    
    %   B->A
    arv = s2.PinStatus.ClearToSend;      %  Check if Sink is ON  and the output buffer empty
    if length(arv) == 2  && s2.BytesToOutput < Nbuffer && cntb_t < Ns
        cntb_t = cntb_t + 1;          % generate new character
        fwrite(s2,Tx_B(cntb_t));
    end
    
    %  Deactivate or activate the receiver
    deactpr = rand(1,1);
    if deactpr <= pr_off
        s2.RequestToSend = 'off';        %  Disable RTS (Rx OFF)
    else
        s2.RequestToSend = 'on';         %  Enable RTS (Rx ON)
        len = s2.BytesAvailable;    % wait to receive a new character
        if len ~= 0
            cntb_r = cntb_r + 1; 
            Rx_B(cntb_r) = fread(s2,1);
        end
    end 

    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\nA->B  Outgoing Characters: %d  of %d  ', cnta_t, Ns);
        fprintf('\nB->A  Incoming Characters: %d  of %d \n', cnta_r, Ns);
        fprintf('\nB->A  Outgoing Characters: %d  of %d  ', cntb_t, Ns);
        fprintf('\nA->B  Incoming Characters: %d  of %d \n', cntb_r, Ns);
        tstart = clock;
    end

end

timedif = etime(clock, tinit);      %  Total time

%%
disp(' ');
disp('Closing the RS232 ports . . . . . ');
record(s1,'off')
fclose(s1)
delete(s1)
clear s1
record(s2,'off')
fclose(s2)
delete(s2)
clear s2
disp('RS232 ports deactivated');

disp(' ');
if sum(Tx_A == Rx_B) == Ns &&  sum(Tx_B == Rx_A) == Ns
  disp('Data exchange without errors');
else
   NeA = sum((Tx_A - Rx_B) ~= 0);
   fprintf('\nA->B:  Data exchange with %d errors in %d data charactes\n', NeA, Ns);
   NeB = sum((Tx_B - Rx_A) ~= 0);
   fprintf('\nB->A:  Data exchange with %d errors in %d data charactes\n', NeB, Ns);
end



fprintf('\nCharacters exchanged: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Ns, timedif, Ns/timedif);

disp(' . . . .  Ending the Characters Gen/Sink Application.');
