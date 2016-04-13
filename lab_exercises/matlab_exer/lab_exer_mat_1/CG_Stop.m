diff = zeros(1,Nc);
for i = 1:Nc-1
  diff(i) = time_vals(i+1) - time_vals(i);
end

x = 1:7;

hist(diff,x)