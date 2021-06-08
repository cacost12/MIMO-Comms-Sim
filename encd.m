function enc = encd(msg, type)

    % Encode input message
    switch type
        case 'null'

            % No encoder
            enc = msg;

        case 'hamm(7,4)'

            % Hamming (7,4)
            G           = [1 1 0 1; 1 0 1 1; 1 0 0 0; ...
                            0 1 1 1; 0 1 0 0; 0 0 1 0; 0 0 0 1].';
            msg         = reshape(msg,[4,length(msg)/4]).';
            enc         = (msg*G).';
            enc         = mod(enc,2);
            enc         = enc(:).';

        case 'hamm(15,11)'
            
            % Hamming (15,11)
            n           = 15;
            k           = 11;
            n_bits      = length(msg);
            xtra        = mod(n_bits,11);
            if mod(n_bits,2) == 1
                msg         = [msg zeros(1,11-xtra)];
            else
                msg         = [msg zeros(1,22-xtra)];
            end
            enc         = encode(msg,n,k,'hamming/binary');
            
        case 'cyclic(15,5)'
            
            % Cyclic Block Code (15,5)
            n           = 15;
            k           = 5;
            genpoly     = cyclpoly(n,k);
            parmat      = cyclgen(n,genpoly);
            n_bits      = length(msg);
            xtra        = mod(n_bits,k);
            if mod(n_bits,2) == 1
                msg         = [msg zeros(1,2*k-xtra)];
            else
                msg         = [msg zeros(1,k-xtra)];
            end
            enc         = encode(msg,n,k,'cyclic/binary',genpoly);
            
    end
end