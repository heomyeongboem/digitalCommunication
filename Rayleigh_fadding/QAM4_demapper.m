
function [bitseq] = QPSK_demapper(symbolseq);

QPSK_table = [1+j -1+j -1-j 1-j ]/sqrt(2.); 
symbolseq_length=length(symbolseq);
bitseq_length=symbolseq_length*2;
bitseq=zeros(1,bitseq_length);
x_temp = [];
temp = zeros(1,2);

for i=1:symbolseq_length
    temp =dec2bin(find(QPSK_table==symbolseq(i))-1,2);
    x_temp = [x_temp temp];
end

for i=1:bitseq_length
     bitseq(i)=bin2dec(x_temp(i));
end
