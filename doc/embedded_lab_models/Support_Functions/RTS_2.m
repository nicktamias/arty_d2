%
%   RTS control on Serial Device s1 
%
if rts_s2 == 1
    s2.RequestToSend = 'on';
else
    s2.RequestToSend = 'off';
end
    
