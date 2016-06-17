clc;
close all;
clear all;

%Add support functions to path
addpath(genpath('support_fn'))

Ts = 1;
Nc = 10;

Nstart = 10;
Nend = 25;

Range = [Nstart Nend];
qs=[1/6 2/5 2/3];

time_vals = zeros(1, Nc);
Tx_array = zeros(1,Nc);

serial_name = 'COM13';
baud_rate = 9600;

input_buf_size = 1;
output_buf_size = 1;

pause_t = 0.1;