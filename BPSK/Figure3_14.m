clear all; close all; 

EbNo_dB = -1:15;
EbNo = 10.^(EbNo_dB./10);
Pb_uni = Q_function(sqrt(EbNo));
Pb_bi = Q_function(sqrt(EbNo*2));

semilogy(EbNo_dB,Pb_uni, 'k-o');
hold on;
semilogy(EbNo_dB,Pb_bi, 'k-*');
xlabel('E_b/N_o [dB]');
ylabel('BER (P_B)');
set(gca,'xlim',[-1 15],'xtick',[-1:1:15],'ylim',[10^(-7) 1]);
legend('unipolar', 'bipolar');, grid;
title('Figure 3.14');
