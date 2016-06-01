disp(' ');
disp('Deactivating RS232 port ......');

fclose(s1);
delete(s1)
clear s1

fprintf('RS232 port %s deactivated\n', serial_name);

if Tx_array == Rx_array
  disp('Data exchange without errors');
else
   Ne = sum((Tx_array - Rx_array) ~= 0);
   fprintf('\nData exchange with %d errors in %d data charactes\n\n', Ne, Nc);
end
