%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%      Φεβρουάριος 2015
%
%      Αρχείο M_Channel_Example.m
%
%      Λαμβάνει τα δεδομένα εισόδου από το αρχείο FILENAME_IN και
%      αποθηκευει τα δεδομένα εξόδου FILENAME_OUT, 
%      αφού πρώτα προστεθεί θόρυβος ή άλλες παραμορφώσεις στο σήμα. 
%      Απεικονίζει τα δείγματα εισόδου και εξόδου σε 'παλμογραφο' και 'αναλυτή φάσματος'.
%
%      Επιλογές:
%      - Λειτουργία σε πεπερασμένο πλήθος δειγμάτων (παράμετρος maxNS) 
%      - Εισαγωγή καθυστέρησης διάδοσης σήματος (παράμετρος samDelay) 
%      - Εισαγωγή θορύβου με συγκεκριμένη ισχύ (παράμετρος Pnoise). 
%      - Εισαγωγή διαφοράς φάσης  με γραμμική παρεμβολή  (παράμετρος phOffset)
%      - Εισαγωγή απόκλισης  χρονισμού (παράμετρος timing_offset)
%
%       H διαφορά φάσης και η απόκλιση χρονισμού δεν εισάγονται ταυτόχρονα.  
%       Αν και τα δύο είναι ενεργοποιημένα, εισάγεται διαφορά φάσης μόνο
%       στο πρώτο δείγμα και στη συνέχεια απόκλιση χρονισμού. 
%
%       H διαφορά φάσης και η απόκλιση χρονισμού δεν μπορεί να εισάγεται
%       ταυτόχρονα.  Αν και τα δύο είναι ενεργοποιημένα, εισάγεται μόνο
%       απόκλιση χρονισμού. Η διακύμανση  χρονισμού εισάγεται μόνο όταν
%       υπάρχει απόκλιση  χρονισμού.
%
%      Για τη διακοπή της εκτέλεσης του  προγράμματος, πατήστε    Cntrl-C    
%      και μετα πρέπει να εκτελεστεί η  εντολή  fclose(sport); clear sport;  στο Command Window .
%
%      Στο Command Window  περιοδικά δίνονται πληροφορίες για την κατάσταση  του συστήματος
%
close all;
clear all;
clc;
scrsz = get(0,'ScreenSize');
disp('Channel emulation:  Starting .....');

FILENAME_IN = 'Tx_Output.mat';
FILENAME_OUT = 'Rx_Input.mat';

load(FILENAME_IN);
   
InChar = OutChar; 
maxNS = length(OutChar);
OutChar  = zeros(1, maxNS); 


%%  Parameters
    samDelay = 0;            %  Delay in number of samples
    Pnoise = 20/1000;         %  Watt,    (No noise = 0)
    phOffset = 0.0;          %  Phase offset  (-1 <   < 1,      -1 = x_{+1},   0 = x_{0},   1 = x_{-1})     
    timing_offset = 0;       %  Timing offset  in ppm   (typical values  -200 ppm to 200 ppm)
    
%  Display parameters
    Ndisp = 512;         %   update parameters
    Nfft = 512;                   %  FFT points
    Nmax = max(Nfft, Ndisp);
    
%  DAC/ADC
    Bdac = 8;
    DRdac = 2;               %  DAC dynamic range,  in Volts
    dac_co_ain = DRdac/(2^Bdac -1);
    dac_co_bin = -DRdac/2;
    dac_co_aout = (2^Bdac -1)/DRdac;
    dac_co_bout = (2^Bdac -1)/2;
    
    if Pnoise > 0
        sgma = sqrt(Pnoise);
    end
    
    Vin = zeros(maxNS, 1);
    Vout = zeros(maxNS, 1); 
    Farrow_taps = [0 0 0 0];          

%%      Data Processing
disp('Processing serial data .....');
fprintf('\nChannel emulator parameters:\n-----------------------------------------');

if maxNS == Inf
    fprintf('\nContinuous Operation');
else
    fprintf('\nSamples to be processed = %d', maxNS);
end

if Pnoise == 0
    fprintf('\nNo noise is introduced');
else
    fprintf('\nNoise power = %6.3f mWatts', Pnoise*1000);
end

if samDelay == 0
    fprintf('\nNo delay is introduced');
else
    fprintf('\nIntroduced delay = %d samples', samDelay);
end

if phOffset == 0
    fprintf('\nNo phase offset is introduced');
else
    fprintf('\nIntroduced phase offset = %d%% of the input sample period', phOffset*100);
end

if  timing_offset == 0
    fprintf('\nNo timing offset is introduced');
else
    fprintf('\nIntroduced timing offset = %d ppm', timing_offset);
end
disp(' ');



cnt_in = 0;
cnt_out = 0;
mu = -abs(phOffset);              %  Initial phase
dmu = timing_offset/1000000;            % Normalized timing difference
    
%%      Insert delay
if samDelay ~= 0         
    while cnt_in < 1
            if len > 0
                cnt_in = cnt_in + 1;
                for i = 1:samDelay
                    cnt_out = cnt_out + 1;
                    OutChar(cnt_out) = round(64*rand(1,1) + 95);
                end
                    cnt_out = cnt_out + 1;
                    OutChar(cnt_out) = InChar(cnt_in);
            end
        end
end
 
%%
while cnt_in < maxNS
            cnt_in = cnt_in + 1;
            Vin(cnt_in) = dac_co_ain*InChar(cnt_in) + dac_co_bin;                 %  Voltage

            if timing_offset == 0                   %%  Only phase offset
                    cnt_out = cnt_out + 1;
                    mu = phOffset;
                    Farrow_taps = [Vin(cnt_in) Farrow_taps(1:3)];
                    u0 = sum(Farrow_taps.* [-1 3 -3 1]/6);
                    u1 = sum(Farrow_taps.* [1 -2 1 0]/2);
                    u2 = sum(Farrow_taps.* [-2 -3 6 -1]/6);
                    u3 = Farrow_taps(2);
                    Val = ((u0*mu + u1)*mu + u2)*mu + u3;
                    if Pnoise > 0               %      Introduce  noise
                            Vout(cnt_out) = Val + sgma*(sqrt(2*log(1/(1-rand(1,1)))))*cos(2*pi*rand(1,1));
                    else          
                            Vout(cnt_out) = Val;
                    end
                    Vout(cnt_out) = min(DRdac/2,  Vout(cnt_out));                         %  Limiter
                    Vout(cnt_out) = max(-DRdac/2,  Vout(cnt_out));
                    OutChar(cnt_out) = dac_co_aout*Vout(cnt_out) + dac_co_bout;
                    
            else
                    mu = mu + dmu;
                    Farrow_taps = [Vin(cnt_in) Farrow_taps(1:3)];
                    u0 = sum(Farrow_taps.* [-1 3 -3 1]/6);
                    u1 = sum(Farrow_taps.* [1 -2 1 0]/2);
                    u2 = sum(Farrow_taps.* [-2 -3 6 -1]/6);
                    u3 = Farrow_taps(2);
                    if mu > 0
                            cnt_out = cnt_out + 1;
                            Val = ((u0*mu + u1)*mu + u2)*mu + u3;
                            if Pnoise > 0               %      Introduce  noise
                                    Vout(cnt_out) = Val + sgma*(sqrt(2*log(1/(1-rand(1,1)))))*cos(2*pi*rand(1,1));
                            else          
                                    Vout(cnt_out) = Val;
                            end
                            Vout(cnt_out) = min(DRdac/2,  Vout(cnt_out));                         %  Limiter
                            Vout(cnt_out) = max(-DRdac/2,  Vout(cnt_out));
                            OutChar(cnt_out) = dac_co_aout*Vout(cnt_out) + dac_co_bout;
                        
                            mu = mu -1;
                            cnt_out = cnt_out + 1;
                            Val = ((u0*mu + u1)*mu + u2)*mu + u3;
                            if Pnoise > 0               %      Introduce  noise
                                    Vout(cnt_out) = Val + sgma*(sqrt(2*log(1/(1-rand(1,1)))))*cos(2*pi*rand(1,1));
                            else          
                                    Vout(cnt_out) = Val;
                            end
                            Vout(cnt_out) = min(DRdac/2,  Vout(cnt_out));                         %  Limiter
                            Vout(cnt_out) = max(-DRdac/2,  Vout(cnt_out));
                            OutChar(cnt_out) = dac_co_aout*Vout(cnt_out) + dac_co_bout;
                        
                    elseif mu < -1
                        mu = mu + 1;
                        
                    else
                            cnt_out = cnt_out + 1;
                            Val = ((u0*mu + u1)*mu + u2)*mu + u3;
                            if Pnoise > 0               %      Introduce  noise
                                    Vout(cnt_out) = Val + sgma*(sqrt(2*log(1/(1-rand(1,1)))))*cos(2*pi*rand(1,1));
                            else          
                                    Vout(cnt_out) = Val;
                            end
                            Vout(cnt_out) = min(DRdac/2,  Vout(cnt_out));                         %  Limiter
                            Vout(cnt_out) = max(-DRdac/2,  Vout(cnt_out));
                            OutChar(cnt_out) = dac_co_aout*Vout(cnt_out) + dac_co_bout;
                    end
        end   
end

%%  Display   

    fprintf('\n Input Power = %4.3f Watt,  Output Power = %4.3f Watt \n', mean(Vin.^2), mean(Vout.^2));

    figure('Position',[scrsz(4)/20 scrsz(4)/20 5*scrsz(3)/6  7*scrsz(4)/8]);
    set(gcf, 'color', 'white');
    FontSize = 14;
    set(gcf,'DefaultLineLineWidth',1);
    set(gcf,'DefaultTextFontSize', FontSize, 'DefaultAxesFontSize', FontSize, 'DefaultLineMarkerSize', 0.25*FontSize);

    subplot(2,2,1)
    tim_in = (0:length(Vin)-1)/(Rsam)*1000;
    plot(tim_in, Vin, 'o-b');
    grid on;
    axis([min(tim_in) max(tim_in) -DRdac/2 DRdac/2]);
    xlabel('Time [msecs]');
    ylabel('Input Voltage [Volts]');
    snapnow


    subplot(2,2,2)
    tim_out = (0:length(Vout)-1)/(Rsam*(1+dmu))*1000 +1000*phOffset/(Rsam*(1+dmu));
    plot(tim_out, Vout, 'd-k');
    grid on;
    axis([min(tim_out) max(tim_out) -DRdac/2 DRdac/2]);
    xlabel('Time [msecs]');
    ylabel('Output Voltage [Volts]');
    snapnow

    subplot(2,2,3)
    Pxx = abs(fft(Vin(cnt_in-Nfft+1:cnt_in), Nfft).^2/(Nfft*Rsam));
    FV = dspdata.psd(Pxx(1:Nfft/2), 'Fs', Rsam);  
    plot(FV.Frequencies/1000, 10*log10(FV.data*1000), 'o-b'); 
    axis([0 Rsam/2000 -50 10]);
    grid on;
    xlabel('Frequency [kHz]');
    ylabel('Input Power [dBm]');
    
    subplot(2,2,4)
    Pxx = abs(fft(Vout(cnt_out-Nfft+1:cnt_out), Nfft).^2/(Nfft*(Rsam*(1+dmu))));
    FV = dspdata.psd(Pxx(1:Nfft/2), 'Fs', Rsam*(1+dmu));  
    plot(FV.Frequencies/1000, 10*log10(FV.data*1000), 'd-k');
    axis([0 Rsam/2000 -50 10]);
    grid on;
    xlabel('Frequency [kHz]');
    ylabel('Output Power [dBm]');
    
%%    
save(FILENAME_OUT);
disp('Done! ....');
disp(' ');
