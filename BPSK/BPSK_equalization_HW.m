%filename:BPSK_equalization_HW.m
clear all; 
%close all; 

Eb = 1;  % assuming Bipolar signaling
Eb_No_start=-1; Eb_No_step=1; Eb_No_end=12;
BER = zeros(1, ceil((Eb_No_end-Eb_No_start+1)/Eb_No_step));
BER_target=10^(-3);
channel = [0.1 0.3 -0.2 1.0 0.4 -0.1 0.1]; % from problem 3.18 

%equalizer selection
tap_number=7;%tap3,5,7 the tap number needs to be a odd number
[equalizer,Delay]=ZFE_design(channel,tap_number);    

frame_size = 100; % number of bits per frame
max_num_frame=10^6;
Observation_SNR=12;

 for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;
    if EbN0dB==Observation_SNR, equalized_symbol_stack=[];   end
     
   for frame_index = 1: max_num_frame    

       %bit stream generation
       %bit_stream=randint(1,frame_size); 
       bit_stream=randi([0,1],1,frame_size); % 0 or1로 구성된 의 1x100 비트스트림
       %bipolar symbol mapping
       symbol_stream=bit_stream;
       temp_index=find(bit_stream==0);
       symbol_stream(temp_index)=-1;
    
        %symbol stream transmission
        rx_symbol_stream = conv(symbol_stream, channel);
        
        %signal power and noise power calculation
        P_s=mean(rx_symbol_stream.^2);
        P_n=P_s*10^(-EbN0dB/10);
        noise = sqrt(P_n);
        
        %noise addition
        rx_symbol_stream= rx_symbol_stream + noise;
        
        %%make equalizer
        %tabs = 7;
        %channel_impulse = equalization_filter(7,channel);
        %c_Filter = channel_impulse' * [0; 1; 0];
        
        %equalization; compensate for the channel distortion
        %equalized_symbol_stream_temp = rx_symbol_stream * equalizer;
        equalized_symbol_stream_temp = Delay * equalizer;

        %remove the delay caused by the equalization process
        equalized_symbol_stream=equalized_symbol_stream_temp(1+Delay:Delay+frame_size);
        
        if (EbN0dB==Observation_SNR)&(frame_index<100)
            equalized_symbol_stack=[equalized_symbol_stack  equalized_symbol_stream];
        end
        
        % symbol stream--> bit stream
        bit_stream_hat=zeros(1,frame_size);
        one_indices=find(equalized_symbol_stream>0);
        bit_stream_hat(one_indices)=1;
        
        %error calculation
        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if error > 200 &(frame_index>100), break;   end
    end %frame_index
        
    BER(EbN0dB+2) = error/(frame_index*frame_size);
    
    if BER(EbN0dB+2) < BER_target | EbN0dB > 30,  break;   end
    
 end% for EbN0dB = Eb_No_start:Eb_No_end,

%figure,semilogy([Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');

hf1 = subplot(1,2,1);
plot(hf1,[Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');
xlabel('E_b/N_o(dB)'); ylabel('P_b'); set(gca,'xlim',[-1 30], 'ylim',[10^(-6) 1]);

hf2 = subplot(1,2,2)
plot(hf2,1:length(equalized_symbol_stack),equalized_symbol_stack(1:length(equalized_symbol_stack)),'o-');
