%Initialize and open serial port
disp('Opening the RS232 port . . . . . ');

s_port = serial('COM4', 'BaudRate', 9600, 'Parity', 'none');
set(s_port, 'InputBufferSize', 1);
set(s_port, 'OutputBufferSize', 1);
fopen(s_port);

disp('RS232 port activated!');

Nc = 10000;
x = 1:Nc;
k = 1;

s_out = zeros(1, Nc);
time_intervals = zeros(1, Nc);

%Plot characters received and time intervals
figure;

tic;
%Wait for incoming data
while(1)
    
    if(s_port.BytesAvailable > 0)
        %Read one character from serial
        s_out(k) = fread(s_port, 1, 'uchar');
        
        %Measure time passed between two character transmissions
        time_intervals(k) = toc;

        %Character values plot
        subplot(2,1,1);
        stem(x, s_out)
        title('Character Values')
        xlabel('Time')
        ylabel('Character Values')

        %Time intervals plot
        subplot(2,1,2);
        hist(time_intervals(1:k))
        title('Time Intervals')
        xlabel('Time')
        ylabel('Time Interval')

        %Force plot refresh
        snapnow;
        
        tic;
        
        if(k==Nc)
            break;
        else
            k=k+1;
        end

    end
end

%Communication END! Deactivate serial port
disp('Closing the RS232 port . . . . . ');

fclose(s_port);
delete(s_port);

disp('RS232 port closed!');