%%mapping bit(200bit) -> symbol100개( 한개당 -> 2bit사용 )
function symbol_stream = QPSK_mapper(bit_stream)
    %%make 1symbol have 2bit 
    symbol_stream = zeros(1,100);
    
    for i = 1:2:200
        %00 ->1
        if bit_stream(i) == 0 && bit_stream(i + 1) == 0
            symbol_stream((i+1)/2) = 1;
        %01 ->j
        elseif bit_stream(i) == 0 && bit_stream(i + 1) == 1
            symbol_stream((i+1)/2) = j;
        %11 ->-1
        elseif bit_stream(i) == 1 && bit_stream(i + 1) == 1
            symbol_stream((i+1)/2) = -1;
        %10 ->-j
        else
            symbol_stream((i+1)/2) = -j;
        end
    end
end


