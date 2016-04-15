disp('Opening the RS232 port . . . . . ');

s_port = serial('COM3', 'BaudRate', 9600, 'Parity', 'none');
set(s_port, 'InputBufferSize', 1);
set(s_port, 'OutputBufferSize', 1);
fopen(s_port);

disp('RS232 port activated!');