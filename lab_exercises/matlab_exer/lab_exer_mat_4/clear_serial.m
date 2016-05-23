fclose('all');
delete(instrfindall);

if isempty(instrfindall)
    disp('All serial ports closed')
else
    error('Serial ports still open')
end

clear all;