%
%   RS232 ports initialization
%
disp('Activating the RS232 ports');
s1 = serial('COM3','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1,'InputBufferSize',1);
set(s1,'OutputBufferSize',1);
set(s1,'RecordDetail', 'verbose');
set(s1,'RecordName', 'record_s1.txt');
fopen(s1)
record(s1)

s2 = serial('COM13','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s2,'InputBufferSize',1);
set(s2,'OutputBufferSize',1);
set(s2,'RecordDetail', 'verbose');
set(s2,'RecordName', 'record_s2.txt');
fopen(s2)
record(s2)
disp('RS232 ports activated');


b2o_s1 = uint8(0);
d2o_s1 = uint8(0);
b2r_s1 = uint8(0);
d2r_s1 = uint8(0);

b2o_s2 = uint8(0);
d2o_s2 = uint8(0);
b2r_s2 = uint8(0);
d2r_s2 = uint8(0);
