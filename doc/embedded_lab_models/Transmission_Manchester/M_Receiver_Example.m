%%
%      Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%      Φεβρουάριος 2015
%
%      Αρχείο M_Receiver_Example.m
%
%      Επεξεργάζεται δεδομένα που περιέχουν 1 πλαίσιο.
%      Διαβάζει το σήμα από αρχείο και εκτυπώνει στοιχεια για το πλαίσιο και 
%      το πακετο που αναγνώρισε.
%      Δυναμική διόρθωση της φάσης μόνο κατά τη διάρκεια του preamble αξιοποιώντας 
%      την έξοδο του Farrow interpolator. 
%      Το RRC ακολουθεί τον Farrow interpolator.
%
close all;
clear all;
clc;

disp('Starting . . . !')

%%   Αρχικοποίηση παραμέτρων
load('Rx_Input.mat');

OutChar = double(OutChar);
Nup = 4;
Rbits = 1000;
Fs = 2*Nup*Rbits;        %  Sampling rate
Nmob = 6*2*Nup;          %  Number of samples used for detecting the middle of bit
Npha = 20;               %  Number of blocks of samples used for estimating the phase offset
Np = 64;                 %  Number of samples for power calculation
Pthe_up = 0.3;           %  Power threshold  for start
Pthe_down = 0.1;         %  Power threshold for end
ph_cor = 0.25;           %  Phase correction factor
   
frame_status = 0;       %  Frame reception status  
                                    %  0 = line idle,  
                                    %  1 = start of frame detected
                                    %  2 = center of bit detected
                                    %  3 = end of preamble/start of data detected
                                    %  4 = correct CRC detected
                                    
%  DAC/ADC
    Bdac = 8;
    DRdac = 2;               %  DAC dynamic range,  in Volts
    dac_co_ain = DRdac/(2^Bdac -1);
    dac_co_bin = -DRdac/2;
    dac_co_aout = (2^Bdac -1)/DRdac;
    dac_co_bout = (2^Bdac -1)/2;

%  RRC filter
    rr = 0.5;                     %  RRC roll-off factor
    Nup = 4;                    %  Upsampling rate
    rgd = 4;                     %  RRC group delay

%   Calculate RRC coefficients
        rcosSpec = fdesign.pulseshaping(Nup, 'Square Root Raised Cosine', 'Nsym,beta', 2*rgd, rr);
        rcosFlt = design(rcosSpec); 
        rcosFltcoefs = rcosFlt.Numerator'/max(rcosFlt.Numerator);
        for m=1:Nup
            vsum(m) = sum(abs(rcosFltcoefs(m:Nup:(1+2*Nup*rgd))));
        end
        rcosFltcoefs = 0.3*rcosFltcoefs'/max(vsum);

Header = reshape(de2bi([85 85 85 85 85 85 85 86], 8, 'left-msb')', 64, 1);                 %  Frame header
len = length(Header);
Ncomp = 14;     %  11 bits
endpreamble = Header(len-Ncomp+1:len);   
endpresympat = [];
for i = 1:Ncomp
    if endpreamble(i) == 0
        endpresympat = [endpresympat -1 1];
    else
        endpresympat = [endpresympat  1 -1];
    end
end
endpresympat = fliplr(endpresympat);
det = crc.detector('Polynomial', '0x8005', 'ReflectInput', true, 'ReflectRemainder', true);   % Create a CRC-16 CRC detector

maxNS = length(OutChar);                             %  Number of samples
LW = 1;         %  Line width
MS = 2;         %  Marker Size

%   Tap(1) is the most recent tap
Power_taps = zeros(1, Np);
RRC_taps = zeros(1, 1+2*Nup*rgd);
Farrow_taps = [0 0 0 0];          
mu = 0;                             % Initial μ value set to 0 
ind_mob = 1;
ind_symb = ind_mob + Nup/2;


disp_prev = 0;
symbol_loc = [];
symbol_val = [];
                                
%%    First sample
Vin(1) = dac_co_ain*OutChar(1) + dac_co_bin;    %  signal as voltage
Power_taps(1) = Vin(1);
Powal(1) = mean(Power_taps);
      
%%%%%%%%%%%   Array's initialization   %%%%%%%%%%
PowVal = zeros(1, maxNS);
Farrow_output = zeros(1, maxNS);
RRC_output = zeros(1, maxNS);
midobit = zeros(1, 4*Nup);

%%
for cnt=2:maxNS
    Vin(cnt) = dac_co_ain*OutChar(cnt) + dac_co_bin;     %  Receive  a new sample   (signal as voltage)
    
%   Calculate the power of the incoming signal
                    PowVal(cnt) = PowVal(cnt-1) + (Vin(cnt)^2 - Power_taps(Np)^2)/Np;           %  Calculate new power value
                    Power_taps(2:Np) = Power_taps(1:(Np-1));                                                      % Shift samples to the left
                    Power_taps(1) = Vin(cnt);                                                                               %  Last  incoming sample

                    if frame_status == 0 &&  PowVal (cnt) > Pthe_up                                         %  Start of Frame detection
                        prev_status = frame_status;
                        frame_status = 1;
                        ind_start = cnt;
                        mob_cnt = 0;
                         fprintf('\n Start of Frame detected at sample %d', ind_start);
                    end
                    if  frame_status > 0
                        if PowVal ((cnt-Nup+1):cnt) < Pthe_down               %  End of Frame detection
                                ind_end = cnt-Nup;
                                fprintf('\n End of Frame detected at sample %d - Incorrect CRC\n', ind_end);
                                
                                prev_status = frame_status;
                                frame_status = 0;
                                mu = 0;
                                PowVal(cnt) = 0;
                                Power_taps = zeros(1, Np);
                                midobit = zeros(1, 4*Nup);
                        end
                    end
                    
   %    Timing correction circuit
                Farrow_taps = [Vin(cnt) Farrow_taps(1:3)];         %  Farrow Filter
                u0 = sum(Farrow_taps.* [-1 3 -3 1]/6);
                u1 = sum(Farrow_taps.* [1 -2 1 0]/2);
                u2 = sum(Farrow_taps.* [-2 -3 6 -1]/6);
                u3 = Farrow_taps(2);
                rmu = -mu;
                Farrow_output(cnt) = ((u0*rmu + u1)*rmu + u2)*rmu + u3; 
     
   %   Filter Incoming signal using RRC 
                RRC_taps = [Farrow_output(cnt)    RRC_taps(1:2*Nup*rgd)  ];  
                RRC_output(cnt) = sum(RRC_taps.*rcosFltcoefs);
        
                
    %   Detect the "middle of bit" sample
        if frame_status == 1
                midobit(mod(cnt-2, 4*Nup)+1) = midobit(mod(cnt-2, 4*Nup)+1) + Farrow_output(cnt);
                midobit(mod(cnt-1, 4*Nup)+1) = midobit(mod(cnt-1, 4*Nup)+1) + Farrow_output(cnt);
                midobit(mod(cnt,   4*Nup)+1) = midobit(mod(cnt,   4*Nup)+1) + Farrow_output(cnt);
                midobit(mod(cnt+1, 4*Nup)+1) = midobit(mod(cnt+1, 4*Nup)+1) + Farrow_output(cnt);
                midobit(mod(cnt+2, 4*Nup)+1) = midobit(mod(cnt+2, 4*Nup)+1) + Farrow_output(cnt);
                mob_cnt = mob_cnt +1;
                
                if mob_cnt == Nmob
                    [val_met  ind_mob] = min(abs(midobit));       %  First sample at the middle of a bit 
                                prev_status = frame_status;
                                frame_status = 2;
                    ind_mob =  cnt - mod(cnt, 4*Nup) + (ind_mob-1); 
                    if ind_mob > cnt
                        ind_mob = ind_mob - 4*Nup;
                    end
                    fprintf('\n Middle of Bit  at samples %d, %d, . . .  ', ind_mob, ind_mob+2*Nup);
                    ind_symb = ind_mob - Nup/2;                              %  First symbol position indicator
                    symb_cen = 0;
                    for i=1:(Nmob/4-3)
                         symb_cen = symb_cen + abs(Farrow_output(ind_mob-Nup/2-i*Nup));          %  Phase correction using Farrow
                    end
                    symb_cen = symb_cen/(Nmob/4-3);
                    presymbols = zeros(1, 2*Ncomp);
                    val_mu = [];
                    val_er = [];
                    val_mb = [];
                    ph_cnt = 0;
                end
        end
        
        
%   Estimate the phase offset using  Farrow output  
        if frame_status == 2    && ph_cnt < Npha  
                if cnt-ind_mob == 4*Nup*round((cnt-ind_mob)/(4*Nup))
                     mu = mu - ph_cor*(Farrow_output(cnt)/0.569)/symb_cen;
                     mu = min(mu, 1);
                     mu = max(mu, -1);
                     ph_cnt = ph_cnt + 1;
                     val_mu = [val_mu mu];
                     val_er = [val_er  -(Farrow_output(cnt)/symb_cen)/0.569];
                end
        end        

            
%   Select the symbol samples, and detect the location of the last preamble symbol
        if frame_status == 2   
                if cnt - ind_symb == Nup*round((cnt - ind_symb)/Nup)
                    if RRC_output(cnt) >=0
                        presymbols = [1 presymbols(1:2*Ncomp-1)]; 
                    else
                        presymbols = [-1 presymbols(1:2*Ncomp-1)]; 
                    end
                end

                if endpresympat == presymbols
                    prev_status = frame_status;
                    frame_status = 3;
                    ind_lapre =  cnt;
                    packet = [];
                    sy2bi = 0;
                     fprintf('\n End of Preamble detected at sample %d  ', ind_lapre);
                end
        end            
 
 %   Recover the frame's data and CRC part
        if frame_status == 3   
                if cnt > ind_lapre  &&   cnt - ind_lapre == Nup*round((cnt - ind_lapre)/Nup)
                    symbol_loc = [symbol_loc cnt];
                    symbol_val = [symbol_val RRC_output(cnt)];
                    if sy2bi == 0
                        if RRC_output(cnt) >=0
                            b1s = 1;
                        else
                            b1s = -1;
                        end
                        sy2bi = 1;
                    else
                        if RRC_output(cnt) >=0
                            b2s = 1;
                        else
                            b2s = -1;
                        end
                        sy2bi = 0;              % New bit detected
                            if b1s == -1 &&  b2s == 1
                                bit = 0;
                            elseif  b1s == 1 &&  b2s == -1
                                bit = 1;
                            else
                                 disp('Violation');
                                bit = 1;
                            end
                            packet = [packet bit];
                            if length(packet) > 32 && length(packet) == 8*round(length(packet)/8)
                                    [outdata error_ind] = detect(det, packet');
                                    if error_ind == 0 
                                        prev_status = frame_status;
                                        frame_status = 4;
                                       fprintf('\n Correct CRC detected.  \n');      
                                    end
                            end
                    end
              end
        end
 
        
%   Transmit/Print the data packet
        if frame_status == 4 
                    len = length(packet);
                    Bytestream = bi2de(reshape(packet(1:len), 8, len/8)', 'left-msb');
                    if Bytestream(1) == SoP
                        disp(' SoP detected');
                    end
                    if Bytestream(len/8-2) == EoP
                        disp(' EoP detected');
                    end
                    fprintf('\n%s\n\n', Bytestream(1:length(Bytestream)-2));

                    prev_status = frame_status;
                    frame_status = 0;
                    mu = 0;
                    PowVal(cnt) = 0;
                    Power_taps = zeros(1, Np);
                    midobit = zeros(1, 4*Nup);
        end
        
  
end
    
disp('..... End!');


