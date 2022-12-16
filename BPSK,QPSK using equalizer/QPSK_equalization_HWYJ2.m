%filename:QPSK_equalization_HW.m
clear all;  
j=sqrt(-1);
Eb_No_start=-1;
Eb_No_step=1;
Eb_No_end=30;
BER = zeros(1, ceil((Eb_No_end-Eb_No_start+1)/Eb_No_step));
channel = [1+0.8j 0.4j -0.1+0.1j 0.6 0.2-0.1j 0.1 0.05+0.01j];

%equalizer selection
tap_number=7;%tap3,5,7 the tap number needs to be a odd number
[equalizer,Delay]=ZFE_design(channel,tap_number);

xvec = linspace(-2,2,100);
yvec = xvec;
frame_size = 200;

for EbN0dB = Eb_No_start:Eb_No_step:Eb_No_end
    error = 0;

    if EbN0dB==12
        figure;
    end
    
    for frame_index = 1: 100000000

        bit_stream=zeros(1,frame_size);
        temp=randn(1,frame_size);
        one_indices=find(temp>0);
        bit_stream(one_indices)=1;
        
        symbol_stream=QPSK_mapper(bit_stream); %200 -> 100
        
        rx_symbol_stream = conv(symbol_stream, channel);
        
        P_s=sum(abs(channel).^2);        
        P_b=P_s/2;
        P_n=P_b*10^(-EbN0dB/10);
        %add noise
        noise =  sqrt(P_n)/sqrt(2)*(randn(1,106)+j*randn(1,106));
        rx_symbol_stream=rx_symbol_stream + noise;

        %Equalization; compensate for the channel distortion
        % channel = 7
        equalized_symbol_stream_temp = conv(rx_symbol_stream,equalizer);
        

        equalized_symbol_stream=equalized_symbol_stream_temp(1:frame_size/2);
        
        if EbN0dB==12&&(frame_index<20)
            hold on, plot(equalized_symbol_stream,'.');

        end

        sliced_symbol_stream=QPSK_slicer(equalized_symbol_stream); % slicing stream 
     
        bit_stream_hat=zeros(1,frame_size);
        bit_stream_hat=QPSK_demapper(sliced_symbol_stream);

        error_index=find(bit_stream_hat~=bit_stream);
        error=error+length(error_index);
        if error > 100, break;    end
                
    end%frame_index = 1: 10^10
    
    if EbN0dB==12
        grid;
        xlabel('Real','fontsize',14);
        ylabel('Imag','fontsize',14);
        title('Equalized Symbols','fontsize',14);
    end

    BER(EbN0dB+2) = error/(frame_index*frame_size);

    if BER(EbN0dB+2) < 10^-3 | EbN0dB > 300
        break;
    end

end% for EbN0dB = Eb_No_start:Eb_No_end,


figure,semilogy([Eb_No_start:Eb_No_step:Eb_No_end],BER,'o-');
xlabel('E_b/N_o(dB)');
ylabel('P_b');
set(gca,'xlim',[-1 30], 'ylim',[10^(-6) 1]);
grid;
function  symbol_stream = QPSK_mapper(bit_stream) %200 -> 100

    %  00 -> 1
    %  01 -> j
    %  11 -> -1
    %  10 -> -j
    symbol_stream =zeros(1,100);
    j= sqrt(-1);
    for i = 1:2:200
        if bit_stream(i) ==0  %0x
            if bit_stream(i+1)==0  %00
                symbol_stream((i+1)/2) =1;
            else                   %01
                symbol_stream((i+1)/2) = j;
            end

        else % 1x
            if bit_stream(i+1)==1  % 11
                symbol_stream((i+1)/2) =-1;
            else
                symbol_stream((i+1)/2) =-j; % 10
            end
        end
    end % for end 

end

function bit_stream_hat=QPSK_demapper(sliced_symbol_stream) %100->200
    %  00 <- 1
    %  01 <- j
    %  11 <- -1
    %  10 <- -j
    j=sqrt(-1);
    bit_stream_hat =zeros(1,200);
    for i=1:100
        if(sliced_symbol_stream(i)==1)
            bit_stream_hat(2*i-1)=0;
            bit_stream_hat(2*i)=0;
        elseif(sliced_symbol_stream(i)==j)
            bit_stream_hat(2*i-1)=0;
            bit_stream_hat(2*i)=1;
        elseif(sliced_symbol_stream(i)==-1)
            bit_stream_hat(2*i-1)=1;
            bit_stream_hat(2*i)=1;
        else %% -j
            bit_stream_hat(2*i-1)=1;
            bit_stream_hat(2*i)=0;
        end
   
    end
end
function sliced_symbol_stream=QPSK_slicer(equalized_symbol_stream) %100 
     % y =x
     % y = -x
     %   equalized_symbol_stream 은 실수 +허수 구성 
     % compare    허수= imag(equalized_symbol_stream(i)) , 실수  =real(equalized_symbol_stream(i))
     %
     j=sqrt(-1);
     sliced_symbol_stream =zeros(1,100);
 for i = 1:100
     x = real(equalized_symbol_stream(i)); % x is bit real
     y = imag(equalized_symbol_stream(i)); % y is bit imag
         if (x>0 && y>0)
             if(y>x)
                 sliced_symbol_stream(i) = j;
             else
                 sliced_symbol_stream(i) =1;
             end
         end
         if(x>0 && y <0)
             if (x>abs(y))
                 sliced_symbol_stream(i) =1;
             else
                 sliced_symbol_stream(i) =-j;
             end
         end
         if(x<0 && y<0)
             if(abs(x)>abs(y))
                 sliced_symbol_stream(i) = -1;
             else
                 sliced_symbol_stream(i)=-j;
             end
         end
         if(x<0 && y>0)
             if(abs(x)<y)
                 sliced_symbol_stream(i) =j;
             else
                 sliced_symbol_stream(i) =-1;
             end
         end
 end %% for end
     
end % function end 