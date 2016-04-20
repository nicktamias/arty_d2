%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%      Φεβρουάριος 2015
%
%      Αρχείο Channel_Character_Errors_RS232.m
%
%       Πρόγραμμα προσομοίωσης καναλιού διπλής κατεύθυνσης που εισάγει λάθη 
%       σε χαρακτήρες που μεταδίδονται μέσω RS232 (χωρίς  HFC)  
%       με δεδομένη πιθανότητα λάθους.
%
clear all;
close all;
clc;
pr_err = 0.01;     %  Πιθανότητα εισαγωγής λάθους
disptime = 2;      %  Χρόνος ενημέρωσης display (secs)
errpattern = uint8([3 12 24 48 192 10 20 40 80 160 36 72 144 129 96 6 5 15 30 60 9 18 66]);

%%
disp('Opening the RS232 ports . . . . . ');
s1 = serial('COM35','BaudRate',38400,'Parity','even', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', 256);
set(s1, 'OutputBufferSize', 256);
fopen(s1)

s2 = serial('COM26','BaudRate',38400,'Parity','even', 'Terminator', '');
set(s2, 'FlowControl', 'none');
set(s2, 'InputBufferSize', 256);
set(s2, 'OutputBufferSize', 256);
fopen(s2)
disp('RS232 ports activated');
disp(' ');

%%  
tstart = clock; 
cnt_AB = 0;
cnt_BA = 0;
err_AB = 0;
err_BA = 0;
while 1
    if s1.BytesAvailable > 0 && s2.BytesToOutput < 250
        val= fread(s1,1);
        cnt_AB = cnt_AB + 1;
        errval = 0;
        deactpr = rand(1,1);
        if deactpr <= pr_err
            err_AB = err_AB + 1;
            errval = errpattern(randi([1 length(errpattern)], 1));
        end
        val = bitxor(val, errval);
        fwrite(s2, val, 'uchar');
    end
    
    if s2.BytesAvailable > 0 && s1.BytesToOutput < 250
        val= fread(s2,1);
        cnt_BA = cnt_BA + 1;
        errval = 0;
        deactpr = rand(1,1);
        if deactpr <= pr_err
            err_BA = err_BA + 1;
            errval = errpattern(randi([1 length(errpattern)], 1));
        end
        val = bitxor(val, errval);
        fwrite(s1, val, 'uchar');
    end
    
    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  A-B: %d,  errors: %d,  ByER:%6.5f', cnt_AB, err_AB, err_AB/cnt_AB);
        fprintf('\n  B-A: %d,  errors: %d,  ByER:%6.5f', cnt_BA, err_BA, err_BA/cnt_BA);
        tstart = clock;
        disp(' ');
    end
end


%%
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

