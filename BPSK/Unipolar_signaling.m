clear all, close all
Ed_uni = 1/2;
BER(1, 17) = 0;
Eb_No_start=-1;
Eb_No_end=15;

for Eb_No = Eb_No_start:Eb_No_end
    error_num = 0;
    for bit = 1 : 10^10
        if randn(1) > 0, 
            tx_data = 1;
        else
            tx_data = 0;
        end
        noise_power = (1/2) * Ed_uni / 10^(Eb_No/10);
        noise = randn * sqrt(noise_power);
        rx_data = tx_data + noise;
        if rx_data > 0.5,
            tx_data_hat = 1;
        else, tx_data_hat = 0;
        end
        if tx_data_hat ~= tx_data
            error_num = error_num +1;
        end
        if error_num > 200
            BER(Eb_No +2) = error_num/bit;
            break;
        end
    end% for bit = 1 : 10^10 
    Eb_No
    BER(Eb_No+2)
            
    if BER(Eb_No+2) < 10^(-3)
        break;
    end
end%for Eb_No = Eb_No_start:Eb_No_end
Eb_No_index = Eb_No_start:Eb_No_end;
figure;
semilogy(Eb_No_index, BER);
set(gca,'xlim',[-1 15],'xtick',[-1:1:15],'ylim',[10^(-7) 1]);
grid;
save Unipolar