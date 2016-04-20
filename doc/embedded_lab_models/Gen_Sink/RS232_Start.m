%
%   RS232 ports initialization
%
disp('Activating the RS232 port');
s1 = serial('COM37','BaudRate',9600,'Parity','even', 'Terminator', '');
set(s1,'InputBufferSize',1);
set(s1,'OutputBufferSize',1);
fopen(s1)
% s1.RecordDetail = 'verbose';
% s1.RecordName = 'S1.txt';
% record(s1,'on')
disp('RS232 port activated');
