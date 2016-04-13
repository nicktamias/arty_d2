clc;
close all;
clear all;

T_Tx = 1;
T_Rx = 1;

Nc = 100;

Nstart = 10;
Nend = 20;

Range = [Nstart Nend];
qs=[1/6 2/5 2/3];

time_vals = zeros(1, Nc);
char_vals = zeros(1,Nc);

Wp = 0;
Rp = 0;
buf_size = 8;

Tx_buf = randi(Range, 1, Nc);
Rx_buf = zeros(1, Nc);
c_buf = zeros(1, buf_size);