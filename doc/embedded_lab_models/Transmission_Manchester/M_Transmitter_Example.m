%%
%  Ενσωματωμένα Επικοινωνιακά Συστήματα
%      
%   Φεβρουάριος 2015
%
%   Αρχείο M_Transmitter_Example.m
%
%   Manchester modulator model and storage to a file.
%
close all;
clear all;
clc;
scrsz = get(0,'ScreenSize');
warning off MATLAB:concatenation:integerInteraction

disp('Manchester Framer/Modulator Starting .....');
FILENAME = 'Tx_Output.mat';
DATA = 'January 2016.......!';

%%      Parameters

%   Simulation 
Rbits = 1000;            % bps

%  RRC filter
    rr = 0.35;                   %  RRC roll-off factor
    Nup = 4;                    %  Upsampling rate
    rgd = 4;                    %  RRC group delay
    Rsam = Nup*Rbits;
 
%  Display parameters
    Ndisp = 128;             %   update parameters in symbols
    
%  DAC
    Bdac = 8;
    DRdac = 2;               %  DAC dynamic range,  in Volts
    dac_co_a1 = (2^Bdac -1)/DRdac;
    dac_co_b1 = (2^Bdac -1)/2;
    dac_co_a2 = DRdac/(2^Bdac -1);
    dac_co_b2 = -DRdac/2;
        
%   Calculate RRC coefficients
        rcosSpec = fdesign.pulseshaping(Nup, 'Square Root Raised Cosine', 'Nsym,beta', 2*rgd, rr);
        rcosFlt = design(rcosSpec); 
        rcosFltcoefs = rcosFlt.Numerator'/max(rcosFlt.Numerator);
        for m=1:Nup
            vsum(m) = sum(abs(rcosFltcoefs(m:Nup:(1+2*Nup*rgd))));
        end
        rcosFltcoefs = rcosFltcoefs'/max(vsum);
        
        Ph = sum(rcosFltcoefs.^2)/length(rcosFltcoefs);
        Th = 2*rgd/Rbits;
        Eh = Ph*Th;
        SoP = 10;                %  Start of packet 
        EoP = 09;                %  End of packet
        
        Samples(1:2*Nup*rgd) = 0;
        
        cnt_out = 0;                   %  Number of output samples
        
        Header = reshape(de2bi([85 85 85 85 85 85 85 86], 8, 'left-msb')', 64, 1);                 %  Frame header
        gen = crc.generator('Polynomial', '0x8005', 'ReflectInput', true, 'ReflectRemainder', true);   % Create a CRC-16 CRC generator

%%       Modulator Model
    fprintf('\n Pulse Energy = %f mJoules', 1000*Eh);
    fprintf('\n Tx Out Power = %4.3f Watt\n', Eh*Rbits);    

    Packet = uint8(DATA);
    sPacket = reshape(de2bi(Packet, 8, 'left-msb')', 8*length(Packet), 1);
    Packet_CRC = generate(gen, sPacket);
    Frame = [Header;  Packet_CRC];            % Generate the frame  
                        Symbols = [];
                        for i=1:length(Frame)
                            if Frame(i) == 1
                                Symbols = [Symbols 1 -1];
                            else
                                Symbols = [Symbols -1 1];
                            end
                        end
                        fprintf('\nFrame size = %d bits', length(Frame));

                        upSymbols = [];
                        for k=1:length(Symbols);                               %  Insert  (Nup-1) zeros
                            upSymbols = [upSymbols Symbols(k)  zeros(1, Nup-1)];
                        end
                        upSymbols = [zeros(1, 2*Nup*rgd+1)  upSymbols  zeros(1, 2*Nup*rgd+1)];

                        txstart = clock;
                        for k=2*Nup*rgd+1:length(upSymbols)
                                tmp = upSymbols(k-(2*Nup*rgd+1)+1:k);
                                Samples(k) = sum(tmp.*rcosFltcoefs);            %  Pulse shape  (Direct FIR)
                                
                                Samples(k) = min(DRdac/2,  Samples(k));                                                %  Limiter
                                Samples(k) = max(-DRdac/2,  Samples(k));
                                DACSamples(k) = round(dac_co_a1*Samples(k) + dac_co_b1);             % DAC characters
                                
                                cnt_out = cnt_out + 1;
                                OutChar(cnt_out) = DACSamples(k);
                        end
                        disp(' ');

                    OutChar = [127*ones(1,2*2*Nup*rgd)  OutChar   127*ones(1,100)];
                    Samples = [zeros(1,2*Nup*rgd)  Samples  zeros(1,100)];
    
%%    End of Session
save(FILENAME);

figure('Position', [50 75 4*scrsz(3)/5 2*scrsz(4)/3]);
set(gcf, 'color', 'white');
FontSize = 14;
set(gcf,'DefaultLineLineWidth',1);
set(gcf,'DefaultTextFontSize', FontSize, 'DefaultAxesFontSize', FontSize, 'DefaultLineMarkerSize', 0.25*FontSize);
cfig(1) = subplot(2,1,1);
plot(1000*(0:length(Samples)-1)/Rsam, Samples, '-ob');
grid on
xlabel('Time [msecs]');
ylabel('Tx Output [Volts]');
axis([0 1000*(length(Samples)-1)/Rsam  -1.1*DRdac/2 1.1*DRdac/2]);

cfig(2) = subplot(2,1,2);
plot(1000*(0:length(OutChar)-1)/Rsam, OutChar, '-ob');
grid on
xlabel('Time [msecs]');
ylabel('DAC values');
axis([0 1000*(length(OutChar)-1)/Rsam  0 255]);
linkaxes(cfig, 'x')

disp('Done! ....');
disp(' ');