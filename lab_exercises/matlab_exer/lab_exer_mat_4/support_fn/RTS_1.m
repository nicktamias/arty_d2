%
%   RTS control on Serial Device s1 
%
if rts_s1 == 1
    s1.RequestToSend = 'on';
else
    s1.RequestToSend = 'off';
end
    
