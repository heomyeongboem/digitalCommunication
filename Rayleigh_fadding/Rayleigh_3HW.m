%filename:Rayleigh_fading.m
%made by Heo Myeong Boem
clear all;  
close all;

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

for i = 1:100
for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;
    
    for frame_index = 1: 100000000
    %for frame_index = 1: 10000
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
        
        len = length(rx_symbol_stream);  
        x = rx_symbol_stream;

        %%Realization of flat Rayleigh fading channel
        %h[i] = 1/sqrt(2) * (randn(1,60) + j * randn(1,60)) i = 1,2,...,Nr
        Nr = 2;
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
            h_abs = [h_abs;abs(h(i,:)).^2]; %|h[i]|^2
            y_hat = [y_hat;abs(h(i,:)).^2.* x + conj(h(i,:)).*n(i,:)];
        end
        
        %x_hat = sum(y_hat[i])/sum(|h[i]|^2)
        if Nr > 1 
        x_hat =  sum(y_hat)./sum(h_abs);
        
        else
            x_hat =  y_hat./h_abs;
        end
            x_tilder = x_hat(1:frame_size/4);  
        %%draw
        if EbN0dB==9&&(frame_index<20)
            hold on, plot(x_tilder,'.'); 
        end
     
        %%slicing
        sliced_symbol_stream=QAM16_slicer(x_tilder); 
        bit_stream_hat=zeros(1,frame_size);

        %%demapper
        bit_stream_hat=QAM16_demapper(sliced_symbol_stream);

        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if error > 300, break;    end
                
    end%frame_index = 1: 10^10
    
    if EbN0dB==9
        grid;
        xlabel('Real','fontsize',14);
        ylabel('Imag','fontsize',14);
        set(gca,'xlim',[-1.5 1.5], 'ylim',[-1.5 1.5]);
        title("Nr = " + Nr)
    end

    BER(EbN0dB+2) = error/(frame_index*frame_size);
    if BER(EbN0dB+2) < 10^-5 || EbN0dB > 30
        break;
    end

end% for EbN0dB = Eb_No_start:Eb_No_end,
end

figure,semilogy([Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');
%title(tap_number);
xlabel('E_b/N_o(dB)');
ylabel('BER');
set(gca,'xlim',[-1 30], 'ylim',[10^(-6) 1]);
grid;
