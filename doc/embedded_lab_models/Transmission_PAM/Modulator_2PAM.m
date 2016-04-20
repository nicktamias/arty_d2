%%
%   Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%   Δεκέμβριος 2015
%
%   Αρχείο Modulator_2PAM.m
%
%   2-PAM (polar) modulator model
%
close all;
clear all;
clc;

%%      Parameters
Nbits = 1000;            % Number of bits generated
Rbits = 1000;            % bps

%  RRC filter
    rr = 0.25;                   %  RRC roll-off factor
    Nup = 4;                     %  Upsampling rate
    rgd = 4;                     %  RRC group delay
    Rsam = Nup*Rbits;

    disp_ind = 0;           % =0 : SRRC  (Rx), ~=0 : RRC (Channel)

%  Display parameters
    Ndisp = 10*Nup;         %   update parameters
    Nfft = 512;                   %  FFT points
    Nmax = max(Nfft, Ndisp);
    
%  DAC
    Bdac = 8;
    DRdac = 2;               %  DAC dynamic range,  in Volts

%   Arrays initialization
        Bits = zeros(Nbits,1);           
        Sym = zeros(Nbits,1);
        Sam = zeros(Nbits*Nup,1);

%   Calculate RRC coefficients
if disp_ind == 0
    disp('SRRC filter - Channel output');
    rcosSpec = fdesign.pulseshaping(Nup, 'Square Root Raised Cosine', 'Nsym,beta', 2*rgd, rr);
else
    disp('RRC filter - Rx detector input');
    rcosSpec = fdesign.pulseshaping(Nup, 'Raised Cosine', 'Nsym,beta', 2*rgd, rr);
end
        rcosFlt = design(rcosSpec); 
        rcosFltcoefs = rcosFlt.Numerator/max(rcosFlt.Numerator);
        
%   Scope
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(4)/20 scrsz(4)/8 scrsz(3)/2  6*scrsz(4)/8]);
set(gcf, 'color', 'white');
FontSize = 13;
set(gcf,'DefaultLineLineWidth',2);
set(gcf,'DefaultTextFontSize', FontSize, 'DefaultAxesFontSize', FontSize, 'DefaultLineMarkerSize', FontSize);


%%       Modulator Model
disp('2-PAM Modulator ....');
disp(' ');


for ns = 1:Nbits
    Bits(ns) =  randi([0, 1]);              % New bit
    Sym(ns) =  2*Bits(ns)-1;            % New symbol
   
    SNup(2*Nup*rgd+(ns-1)*Nup+1:2*Nup*rgd+ns*Nup) = [Sym(ns) zeros(1, Nup-1)];         %  Insert  (Nup-1) zeros
    for m=1:Nup                                                                                                                         %  Pulse shape  (Direct FIR)
        len = 2*Nup*rgd+ns*Nup;
        tmp = SNup(len+m-Nup-2*Nup*rgd:len+m-Nup);
        Sam((ns-1)*Nup+m) = sum(tmp.*rcosFltcoefs);
    end


%  Display   
    if (Ndisp*round(ns*Nup/Ndisp) == ns*Nup) && (ns >= Nmax) && (ns*Nup >= Nfft)
        len = ns*Nup;
        tim = (len-Nup*Ndisp+1:len)/(Rbits*Nup)*1000;
        plot(tim, Sam(len-Nup*Ndisp+1:len), '.-', 'MarkerEdgeColor', 'r');
        hold on
        axis([min(tim) max(tim) -2*DRdac/2 2*DRdac/2]);
        xlabel('Time [msecs]');
        ylabel('Output Voltage [Volts]');
        grid on
        snapnow
        pause(0.5)
    end
end


%%     
disp('Done! ....');
disp(' ');
