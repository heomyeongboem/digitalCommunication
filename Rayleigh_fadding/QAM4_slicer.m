
function [sliced_symbolseq] = QPSK_slicer(symbolseq)

symbolseq_length=length(symbolseq);
sliced_symbolseq=zeros(1,symbolseq_length);

for i=1:symbolseq_length
    real_part=real(symbolseq(i));
    imag_part=imag(symbolseq(i));
    
    if (real_part>0)&&(imag_part>0)
        sliced_symbolseq(i)= (1+j)/sqrt(2.);
    elseif (real_part<0)&&(imag_part>0)
        sliced_symbolseq(i)= (-1+j)/sqrt(2.);
    elseif (real_part<0)&&(imag_part<0)
        sliced_symbolseq(i)=(-1-j)/sqrt(2.);
    elseif (real_part>0)&&(imag_part<0)
        sliced_symbolseq(i)=(1-j)/sqrt(2.);
    end
end
