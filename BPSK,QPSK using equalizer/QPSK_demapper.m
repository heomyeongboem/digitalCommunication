function bit_stream_hat = QPSK_demapper(sliced_symbol_stream)
%QPSK_DEMAPPER 이 함수의 요약 설명 위치
%   자세한 설명 위치
    len = length(sliced_symbol_stream) ;
    bit_stream_hat = zeros(1,len * 2);
    for i = 1 : len
        %1 ->00
        if sliced_symbol_stream(i) == 1
            bit_stream_hat(i * 2 - 1) = 0;
            bit_stream_hat(i * 2) = 0; 
        %j ->01
        elseif sliced_symbol_stream(i) == j
            bit_stream_hat(i * 2 - 1) = 0;
            bit_stream_hat(i * 2) = 1;
        %-1 -> 11
        elseif sliced_symbol_stream(i) == -1
            bit_stream_hat(i * 2 - 1) = 1;
            bit_stream_hat(i * 2) = 1;
        % -j -> 10
        elseif sliced_symbol_stream(i) == -j
            bit_stream_hat(i * 2 - 1) = 1;
            bit_stream_hat(i * 2) = 0;    
        end
    end
end

