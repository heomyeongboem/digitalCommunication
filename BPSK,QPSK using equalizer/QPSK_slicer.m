%%boundary decision
function sliced_symbol_stream=QPSK_slicer(equalized_symbol_stream)
%%실수와 허수로 나눠서 

len = length(equalized_symbol_stream);
sliced_symbol_stream = zeros(len,1); %저장할 배열 
%sliced_symbol_stream = []
%원래 보낸 신호가 뭔지를 찾아내기 위해 noise가 섞인 signal 이 위치한 decision boudary 찾기 
for i = 1:length(equalized_symbol_stream)
    num = equalized_symbol_stream(i);
    real_num = real(num);
    imag_num = imag(num);
    position = check(real_num,imag_num);
    sliced_symbol_stream(i) = position;
end
end

%% real_num == x , imag_num == y  
function position = check(x,y)
    %제 1사분면 
    if (y < x) & (y > -x)
        position = 1;
    %제 2사분면 
    elseif (y > x) & (y > -x)
        position = j;
    %제 3사분면 
    elseif (y > x) & (y < -x)
        position = -1;
    %제 4사분면
    elseif(y < x) & (y < -x)
        position = -j;
    end
end