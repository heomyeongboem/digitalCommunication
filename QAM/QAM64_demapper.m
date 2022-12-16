%File_name: QAM64_demapper.m
function [bit_stream] =QAM64_demapper(symbol_stream)

bits_of_one_symbol = 6; %64QAM ¿Ãπ«∑Œ
symbol_length = length(symbol_stream);

bit_stream_length = symbol_length * bits_of_one_symbol;

j =sqrt(-1);

QAM_table2 = [-7+7*j,-7+5*j, -7+1*j, -7+3*j, -7-7*j,-7-5*j, -7-1*j, -7-3*j,...
              -5+7*j,-5+5*j, -5+1*j, -5+3*j, -5-7*j,-5-5*j, -5-1*j, -5-3*j,...
              -1+7*j,-1+5*j, -1+1*j, -1+3*j, -1-7*j,-1-5*j, -1-1*j, -1-3*j,...
              -3+7*j,-3+5*j, -3+1*j, -3+3*j, -3-7*j,-3-5*j, -3-1*j, -3-3*j,...
               7+7*j, 7+5*j,  7+1*j,  7+3*j,  7-7*j, 7-5*j,  7-1*j,  7-3*j,...
               5+7*j, 5+5*j,  5+1*j,  5+3*j,  5-7*j, 5-5*j,  5-1*j,  5-3*j,...
               1+7*j, 1+5*j,  1+1*j,  1+3*j,  1-7*j, 1-5*j,  1-1*j,  1-3*j,...
               3+7*j, 3+5*j,  3+1*j,  3+3*j,  3-7*j, 3-5*j,  3-1*j,  3-3*j,...
                ]/sqrt(42.);  

temp = [];
binary = zeros(1, bits_of_one_symbol);
for m=0: symbol_length- 1
    decimal_value = find(QAM_table2==symbol_stream(m+1)) - 1;
    binary = dec2bin(decimal_value, bits_of_one_symbol);
    temp = [temp binary];
end 

for i = 1: length(temp)
    bit_stream(i) = bin2dec(temp(i));
end