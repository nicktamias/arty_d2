%
%   CTS sense on Serial Device s2 
%
arv = s2.PinStatus.ClearToSend;
if length(arv) == 2
    cts_s2 = 1;
else
    cts_s2 = 0;
end
