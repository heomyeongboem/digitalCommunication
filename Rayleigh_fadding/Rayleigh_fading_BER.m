%%Rayleigh_fading_BER vs Eb/N0
clear all;
clf;

[Eb_No_start1,Eb_No_step1,Eb_No_end1,BER1] = Rayleigh(1);
[Eb_No_start2,Eb_No_step2,Eb_No_end2,BER2] = Rayleigh(2);
[Eb_No_start3,Eb_No_step3,Eb_No_end3,BER3] = Rayleigh(3);
[Eb_No_start4,Eb_No_step4,Eb_No_end4,BER4] = Rayleigh(4);
[Eb_No_start5,Eb_No_step5,Eb_No_end5,BER5] = zfe_tap(16);
semilogy([Eb_No_start1:Eb_No_step1:Eb_No_end1],BER1,'o-', ...
        [Eb_No_start2:Eb_No_step2:Eb_No_end2],BER2,'s-' ,...
        [Eb_No_start3:Eb_No_step3:Eb_No_end3],BER3,'d-' ,...
        [Eb_No_start4:Eb_No_step4:Eb_No_end4],BER4,'<-' ,...
        [Eb_No_start5:Eb_No_step5:Eb_No_end5],BER5,'*-');
legend('1 Rx antennas(simualted)','2 Rx antennas(simualted)','3 Rx antennas(simualted)','4 Rx antennas(simualted)','16QAM(AWGN)')
xlabel('E_b/N_o(dB)');
ylabel('BER');
set(gca,'xlim',[-1 20], 'ylim',[10^(-6) 10^(0)]);
grid;

function [Eb_No_start,Eb_No_step,Eb_No_end,BER] = Rayleigh(Nr)
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

    for frame_index = 1: 100000000
        bit_stream=zeros(1,frame_size);
        temp=randn(1,frame_size);
        one_indices=find(temp>0);
        bit_stream(one_indices)=1;
        
        %%mapper
        symbol_stream=QAM16_mapper(bit_stream); %%mapper
        rx_symbol_stream = symbol_stream;

        P_s=sum(abs(channel).^2);        
        P_b=P_s/2;
        P_n=P_b*10^(-EbN0dB/10);
        
        %additive noise
        len = length(rx_symbol_stream);  
        x = rx_symbol_stream;

        %Realization of flat Rayleigh fading channel
        %Nr = 4;
        h = [];
        n = [];
        for i = 1:Nr
            h = [h;1/ sqrt(2) * (randn(1,len) + j * randn(1,len))];
            n = [n;sqrt(P_n)/ sqrt(2) * (randn(1,len) + j * randn(1,len))];
        end
        %y[i] = h[i]*x + n[i]
        y = [];
        for i = 1:Nr
            y = [y;h(i,:).*x(:) + n(i,:)];
        end
        
        %y_hat[i] = |h[i]|^2 + h[i]_conjugate * n[i]
        y_hat = [];
        h_abs = [];
        for i = 1:Nr
            h_abs = [h_abs;abs(h(i,:)).^2];
            y_hat = [y_hat;abs(h(i,:)).^2.* x + conj(h(i,:)).*n(i,:)];
        end
        
        %x_hat

        if Nr > 1 
        x_hat =  sum(y_hat)./sum(h_abs);
        
        else
            x_hat =  y_hat./h_abs;
        end
        x_tilder = x_hat(1:frame_size/4);  
     
        %%slicing
        sliced_symbol_stream=QAM16_slicer(x_tilder); 
        bit_stream_hat=zeros(1,frame_size);

        %%demapper
        bit_stream_hat=QAM16_demapper(sliced_symbol_stream);

        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if error > 300, break;    end
                
    end%frame_index = 1: 10^10
    
    BER(EbN0dB+2) = error/(frame_index*frame_size);
    if BER(EbN0dB+2) < 10^-5 || EbN0dB > 30
        break;
    end

end% for EbN0dB = Eb_No_start:Eb_No_end,
end

%%16QAM
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

