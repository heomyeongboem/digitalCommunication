%file_name: QAM64_slicer.m

function [sliced_symbol_stream]  =  QAM64_slicer(distorted_symbol_sequence)

length_sequence = length(distorted_symbol_sequence);
real_term = zeros(1, length_sequence);
imag_term = zeros(1, length_sequence);
real_term_hat = zeros(1, length_sequence);
imag_term_hat = zeros(1, length_sequence);

sliced_symbol_stream = zeros(1, length_sequence);

% real part
for i = 1: length_sequence
    real_term(i) = real(distorted_symbol_sequence(i));
   
    if(real_term(i) < -6/sqrt(42.))
        real_term_hat(i) = -7/sqrt(42.);
    elseif(real_term(i) < -4/sqrt(42.))
        real_term_hat(i) = -5/sqrt(42.);
    elseif(real_term(i) < -2/sqrt(42.))
        real_term_hat(i) = -3/sqrt(42.);
    elseif(real_term(i) < 0/sqrt(42.))
        real_term_hat(i) = -1/sqrt(42.);
    elseif(real_term(i) < 2/sqrt(42.))
        real_term_hat(i) = 1/sqrt(42.);
    elseif(real_term(i) < 4/sqrt(42.))
        real_term_hat(i) = 3/sqrt(42.);
    elseif(real_term(i) < 6/sqrt(42.))
        real_term_hat(i) = 5/sqrt(42.);
    elseif(real_term(i) >= 6/sqrt(42.))
        real_term_hat(i) = 7/sqrt(42.);
    end
end

% image part
for i = 1: length_sequence
    imag_term(i) = imag(distorted_symbol_sequence(i));
    
    if(imag_term(i) < -6/sqrt(42.))
        imag_term_hat(i) = -7j/sqrt(42.);
    elseif(imag_term(i) < -4/sqrt(42.))
        imag_term_hat(i) = -5j/sqrt(42.);
    elseif(imag_term(i) < -2/sqrt(42.))
        imag_term_hat(i) = -3j/sqrt(42.);
    elseif(imag_term(i) < 0/sqrt(42.))
        imag_term_hat(i) = -j/sqrt(42.);
    elseif(imag_term(i) < 2/sqrt(42.))
        imag_term_hat(i) = j/sqrt(42.);
    elseif(imag_term(i) < 4/sqrt(42.))
        imag_term_hat(i) = 3j/sqrt(42.);
    elseif(imag_term(i) < 6/sqrt(42.))
        imag_term_hat(i) = 5j/sqrt(42.);
    elseif(imag_term(i) >= 6/sqrt(42.))
        imag_term_hat(i) = 7j/sqrt(42.);
    end
end

% Image와 Real 부분 더하기

for i = 1: length_sequence
    sliced_symbol_stream(i) = real_term_hat(i) + imag_term_hat(i);
end

        
    
    
