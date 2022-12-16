clear all;
clf;

[Eb_No_start,Eb_No_step,Eb_No_end,BER] = zfe_tap(4);
[Eb_No_start4,Eb_No_step4,Eb_No_end5,BER4] = zfe_tap(16);
[Eb_No_start6,Eb_No_step6,Eb_No_end6,BER6] = zfe_tap(64);

semilogy([Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-',...
    [Eb_No_start4:Eb_No_step4:Eb_No_end5],BER4,'s-',...
    [Eb_No_start6:Eb_No_step6:Eb_No_end6],BER6,'^-');
legend('4_QAM(simualted)','16_QAM(simualted)','64_QAM(simualted)')
xlabel('E_b/N_o(dB)');
ylabel('BER');
set(gca,'xlim',[-1 20], 'ylim',[10^(-6) 1]);
grid;

function [Eb_No_start,Eb_No_step,Eb_No_end,BER] = zfe_tap(QAM)
j=sqrt(-1);
Eb_No_start=-1;
Eb_No_step=1;
Eb_No_end=30;
BER = zeros(1, ceil((Eb_No_end-Eb_No_start+1)/Eb_No_step));
channel = [1+0.8j 0.5j -0.1+0.1j 0.1 0.02-0.01j 0.1 0.05+0.01j];

%equalizer selection
tap_number=7;%tap3,5,7 the tap number needs to be a odd number
[equalizer,Delay]=ZFE_design(channel,tap_number);


frame_size = 240;

for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;
    %for frame_index = 1: 100000000
    for frame_index = 1: 10000

        bit_stream=zeros(1,frame_size);
        temp=randn(1,frame_size);
        one_indices=find(temp>0);
        bit_stream(one_indices)=1;
        
        if QAM == 4
            symbol_stream=QAM4_mapper(bit_stream);
        elseif QAM == 16
            symbol_stream=QAM16_mapper(bit_stream);
        elseif QAM == 64
            symbol_stream=QAM64_mapper(bit_stream);
        end
        
        rx_symbol_stream = conv(symbol_stream, channel);

        P_s=sum(abs(channel).^2);        
        P_b=P_s/2;
        P_n=P_b*10^(-EbN0dB/10);
        
        %%receiver: r(t) = s(t) + n(t)
        %additive noise
        len = length(rx_symbol_stream);
        noise = sqrt(P_n)/ sqrt(2) * (randn(1,len) + j * randn(1,len));
        rx_symbol_stream=rx_symbol_stream + noise;
        
        %%equalizer    
        equalized_symbol_stream_temp = conv(rx_symbol_stream,equalizer);
        
        if QAM == 4
            equalized_symbol_stream=equalized_symbol_stream_temp(1:frame_size/2);
            sliced_symbol_stream=QAM4_slicer(equalized_symbol_stream);
            bit_stream_hat=zeros(1,frame_size);
            bit_stream_hat=QAM4_demapper(sliced_symbol_stream);
        elseif QAM == 16
            equalized_symbol_stream=equalized_symbol_stream_temp(1:frame_size/4);
            sliced_symbol_stream=QAM16_slicer(equalized_symbol_stream);
            bit_stream_hat=zeros(1,frame_size);
            bit_stream_hat=QAM16_demapper(sliced_symbol_stream);
        elseif QAM == 64
            equalized_symbol_stream=equalized_symbol_stream_temp(1:frame_size/6);
            sliced_symbol_stream=QAM64_slicer(equalized_symbol_stream);
            bit_stream_hat=zeros(1,frame_size);
            bit_stream_hat=QAM64_demapper(sliced_symbol_stream);
        end

        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        %if error > 100, break;    end
                
    end%frame_index = 1: 10^10
    
    BER(EbN0dB+2) = error/(frame_index*frame_size);
    if BER(EbN0dB+2) < 10^-5 || EbN0dB > 30
        break;
    end

end% for EbN0dB = Eb_No_start:Eb_No_end,
end


