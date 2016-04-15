clc;
close all;
clear all;

Ts = 1;
Nc = 100;

Nstart = 10;
Nend = 20;

Range = [Nstart Nend];
qs=[1/6 2/5 2/3];

time_vals = zeros(1, Nc);
char_vals = zeros(1,Nc);

pause_t=0.3;