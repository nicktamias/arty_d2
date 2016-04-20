%
%   RS232 port release
%
disp('Deactivating RS232 port ......');

fclose(s1)
delete(s1)
clear s1


disp('RS232 port deactivated');
  
