clc;
close all;
clear all;

Ts = 1;
Nc = 10;

Nstart = 10;
Nend = 30;

Range = [Nstart Nend];
qs=[1/6 2/5 2/3];

time_vals = zeros(1, Nc);
char_vals = zeros(1, Nc);
recv_data = zeros(1, Nc);
char_data = zeros(1, 2*Nc);

del = hex2dec('10');
xon = hex2dec('14');
xoff = hex2dec('15');
xor_pat = hex2dec('20');