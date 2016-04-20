%
%   RS232 ports release
%
disp('Deactivating RS232 ports ......');

fclose(s1)
delete(s1)
clear s1

fclose(s2)
delete(s2)
clear s2

disp('RS232 ports deactivated');