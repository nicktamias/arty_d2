disp('Closing the RS232 port . . . . . ');

fclose(s_port);
delete(s_port);
clear s_port;

disp('RS232 port closed!');

%for i = 1:Nc-1
  %diff(i) = time_vals(i+1) - time_vals(i);
%end

%x = 1:7;

%hist(diff,x)