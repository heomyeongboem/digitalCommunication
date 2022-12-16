clear all;
clf;

[Eb_No_start,Eb_No_step,Eb_No_end,BER] = zfe_tap(3);
[Eb_No_start5,Eb_No_step5,Eb_No_end5,BER5] = zfe_tap(5);
[Eb_No_start7,Eb_No_step7,Eb_No_end7,BER7] = zfe_tap(7);

semilogy([Eb_No_start7:Eb_No_step7:Eb_No_end7],BER7,'^-',...
    [Eb_No_start5:Eb_No_step5:Eb_No_end5],BER5,'s-',...
    [Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');
legend('7 tap ZFE','5 tap ZFE','3 tap ZFE')
xlabel('E_b/N_o(dB)');
ylabel('P_b');
set(gca,'xlim',[-1 30], 'ylim',[10^(-6) 1]);
grid;

legend

function [Eb_No_start,Eb_No_step,Eb_No_end,BER] = zfe_tap(tap)
j=sqrt(-1);
Eb_No_start=-1;
Eb_No_step=1;
Eb_No_end=30;
BER = zeros(1, ceil((Eb_No_end-Eb_No_start+1)/Eb_No_step));
channel = [1+0.8j 0.4j -0.1+0.1j 0.6 0.2-0.1j 0.1 0.05+0.01j];

%equalizer selection
tap_number=tap;%tap3,5,7 the tap number needs to be a odd number
[equalizer,Delay]=ZFE_design(channel,tap_number);


frame_size = 200;

for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;
    for frame_index = 1: 100000000

        bit_stream=zeros(1,frame_size);
        temp=randn(1,frame_size);
        one_indices=find(temp>0);
        bit_stream(one_indices)=1;
        
        symbol_stream=QPSK_mapper(bit_stream);

        rx_symbol_stream = conv(symbol_stream, channel);

        P_s=sum(abs(channel).^2);        
        P_b=P_s/2;
        P_n=P_b*10^(-EbN0dB/10);
        
        %%receiver: r(t) = s(t) + n(t)
        %additive noise
        noise = sqrt(P_n)/ sqrt(2) * (randn(1,106) + j * randn(1,106));
        rx_symbol_stream=rx_symbol_stream + noise;
        
        %%equalizer    
        equalized_symbol_stream_temp = conv(rx_symbol_stream,equalizer);
        

        equalized_symbol_stream=equalized_symbol_stream_temp(1:frame_size/2);

        sliced_symbol_stream=QPSK_slicer(equalized_symbol_stream);

        bit_stream_hat=zeros(1,frame_size);
        bit_stream_hat=QPSK_demapper(sliced_symbol_stream);

        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if error > 100, break;    end
                
    end%frame_index = 1: 10^10
    
    BER(EbN0dB+2) = error/(frame_index*frame_size);
    if BER(EbN0dB+2) < 10^-3 || EbN0dB > 30
        break;
    end

end% for EbN0dB = Eb_No_start:Eb_No_end,
end


