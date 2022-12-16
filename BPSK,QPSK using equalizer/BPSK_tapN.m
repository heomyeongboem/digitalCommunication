%filename:BPSK_equalization_HW.m
function BER = BPSK_N(num);
Eb = 1;  % assuming Bipolar signaling
Eb_No_start=-1; Eb_No_step=1; Eb_No_end=12;

BER = zeros(1, ceil((Eb_No_end-Eb_No_start+1)/Eb_No_step));

%bit per error
BER_target=10^(-3); % error 10^-3 limit
channel = [0.1 0.3 -0.2 1.0 0.4 -0.1 0.1]; % from problem 3.18 

% %equalizer selection
 tap_number=num;%tap3,5,7 ,N the tap number needs to be a odd number
 [equalizer,Delay]=ZFE_design(channel,tap_number);    

frame_size = 100; % number of bits per frame
max_num_frame=10^6;
Observation_SNR=12;


 for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;
    if EbN0dB==Observation_SNR 
        equalized_symbol_stack=[]; 
        % 반복문 종료시 symbol stack 초기화 
    end
     
   for frame_index = 1: max_num_frame    

       %bit stream generation
       bit_stream=randi([0,1],1,frame_size); % 0 or1로 구성된 의 1x100 비트스트림
       
       %bipolar symbol mapping
       symbol_stream=bit_stream;
       temp_index=find(bit_stream==0); 
       symbol_stream(temp_index)=-1;%bipolar: 0 or 1  => -1 or 1
    
        %symbol stream transmission
        rx_symbol_stream = conv(symbol_stream, channel);
        % rx_symbol_stream = stream(-1,1 로 구성된 1x100 vector) 
        % [0.1 0.3-0.2 1.0 0.4 -0.1 0.1];의 convolution
        
        %signal power and noise power calculation
        P_s=mean(rx_symbol_stream.^2); % signal power
        P_n=P_s*10^(-EbN0dB/10); % noise power 
        
        %noise addition
        noise = randn *sqrt(P_n);
        rx_symbol_stream=rx_symbol_stream+ noise;% 노이즈 추가 

        %bit stream: 송신신호(original) 0 or 1
        % symbol_stream : bit stream => -1 or 1
        %rx_symbol_stream: 수신symbol stream (노이즈+ convolution)
        % equalized_symbol_stream_temp = rx_symbol_stream 의 equalizion 결과
        % equalized_symbol_stream =equalized_symbol_stream_temp의 delay 부분 제거
        %bit_ stream_hat:최종 수신신호(hat)  eq>0 이면 1 else 0
    
       
        %%Equalization; compensate for the channel distortion
        H=[]; % H matrix initalize
        h=rx_symbol_stream;
        C=[h zeros(1,length(h)-1)]';
        R=[h(1) zeros(1,tap_number-1)];
        H=toeplitz(C,R);
        equalized_symbol_stream_temp = H*equalizer;
  
        %remove the delay caused by the equalization process  Delay 부분 제거 
        equalized_symbol_stream=equalized_symbol_stream_temp(1+Delay:Delay+frame_size);
        
        if (EbN0dB==Observation_SNR)&&(frame_index<100)
            equalized_symbol_stack=[equalized_symbol_stack  equalized_symbol_stream];
        end
        
        % symbol stream--> bit stream
        bit_stream_hat=zeros(1,frame_size);
        one_indices=find(equalized_symbol_stream>0);
        bit_stream_hat(one_indices)=1;
        % 최종 수신 신호 : equalized_symbol_stream >0 이면 1 이외 0
        
        %error calculation
        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if (error > 200) && (frame_index>100)
            break;   
        end
    end %frame_index
        
    BER(EbN0dB+2) = error/(frame_index*frame_size);
    
    if ((BER(EbN0dB+2) < BER_target) || (EbN0dB > 30))
        break;   
    end
    
 end% for EbN0dB = Eb_No_start:Eb_No_end,
end
% %% semilogy BER 성능 커브 그리기
% 
% figure,semilogy([Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');
% xlabel('E_b/N_o(dB)'); ylabel('P_b'); set(gca,'xlim',[-1 30], 'ylim',[10^(-6) 1]);