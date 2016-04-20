%
%   CTS sense on Serial Device s1 
%
arv = s1.PinStatus.ClearToSend;
if length(arv) == 2
    cts_s1 = 1;
else
    cts_s1 = 0;
end
