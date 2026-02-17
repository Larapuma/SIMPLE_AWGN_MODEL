%~= - !=
% mod - %
% fix(A/b) - /

% "0000000100100011010001010110011110001001101010111100110111101111"
% 00: -3; 01: -1; 11: 1; 10: 3 для |Re|. 
% 00: 3, 01: 1, 11: -1, 10: -3 для |Im|
% Также первые два бита это Re, а вторые два бита это Im 
% Ex: 0000 (-3,3i); 1000 (3,3i); 1111(1,-1)

binary_message = gen(20000000)
z = (QAM16_modulated(binary_message));

z_gauss = awgn_add(z);

r = QAM16_demodulated(z_gauss)

figure;
plot(real(z), imag(z), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
grid on;
title('16-QAM Constellation');
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
axis equal;
xlim([-4 4]);
ylim([-4 4]);



function res = QAM16_demodulated(signal)
    constellation = [-3+3j, -1+3j, 1+3j,3+3j; ...
                      -3+1j, -1+1j, 1+1j, 3+1j; ...
                      -3-1j, -1-1j, 1-1j, 3-1j; ...
                       -3-3j, -1-3j, 1-3j,3-3j];
    const_vec = constellation(:);
    res = [];
    for i=1:length(signal)
        min_dist = inf;
        s = 0;
        for j = 1:length(const_vec)
            diff = abs(signal(i) - (constellation(j)));
            if diff < min_dist
                min_dist = diff;
                s = j-1;
            end
        end

        bit_12 = string(dec2bin(mod(s,4),2));
        bit_34 = string(dec2bin((fix(s/4)), 2));
        
        res = [res,bit_12+bit_34];
    end
    res = join(res,"");
end


function signal = awgn_add(signal)
    for j = 1:length(signal);
        signal(j) = signal(j) + 0.004*(randn()+i*randn());
    end
end


function res = QAM16_modulated(seq) 
    constellation = [-3+3j, -1+3j, 1+3j,3+3j; ...
                      -3+1j, -1+1j, 1+1j, 3+1j; ...
                      -3-1j, -1-1j, 1-1j, 3-1j; ...
                       -3-3j, -1-3j, 1-3j,3-3j];
    
    seq_size = strlength(seq) / 4;
    res = [];
    
    for i = 1:seq_size
        
        start_idx = (i-1)*4 + 1;
        end_idx = (i-1)*4 + 4;
        substr = extractBetween(seq, start_idx, end_idx); 
        
        Re = convert_to_10(extractBetween(substr, 1, 2));
        Im = convert_to_10(extractBetween(substr, 3, 4));
        
        num = constellation(Re+1, Im+1);
        res = [res, num];
    end
end


function res = convert_to_10(num)
    res = 0;
    len  = strlength(num);
    for i=1:len 
        bit = str2double(extractBetween(num, i, i));
        res = res + bit * 2^(len-i);
    end
    
    
end






function res = gen(len)
    random_num = randi([len,len*len + 1]);
    res = to_binary(random_num);
end



function bit_sequence = to_binary(num)
    if num == 0
        bit_sequence = "0";
        return;
    end
    
    bit_sequence = "";
    while num ~= 0
        bit_sequence = bit_sequence + string(mod(num, 2));
        num = fix(num / 2);
    end
    
    remainder = mod(strlength(bit_sequence), 4);
    if remainder ~= 0
        zeros_needed = 4 - remainder;
        padding = repmat("0", 1, zeros_needed);
        padding = join(padding, "");
        bit_sequence = bit_sequence + padding;
    end
    
    bit_sequence = reverse(bit_sequence);
end

