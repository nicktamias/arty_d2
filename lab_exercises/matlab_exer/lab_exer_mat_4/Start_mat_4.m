disp('Opening the RS232 port . . . . . ');

%Set serial port properties
s1 = serial(serial_name, 'BaudRate', baud_rate, 'Parity', 'none');
set(s1, 'InputBufferSize', input_buf_size);
set(s1, 'OutputBufferSize', output_buf_size);
fopen(s1);

%s1.RecordDetail = 'verbose';
%s1.RecordName = 's1_record.txt';
%record(s1,'on')

%Initialize support function variables
b2o_s1 = uint8(0);
d2o_s1 = uint8(0);
b2r_s1 = uint8(0);
d2r_s1 = uint8(0);
rts_s1 = uint8(0);
cts_s1 = uint8(0);

fprintf('RS232 port %s activated\n', serial_name);