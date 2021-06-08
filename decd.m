function dec = decd(msg, type)

    % Decode received message
    switch type
        case 'null'
            
            % No encoder
            dec = msg;
            
        case 'hamm(7,4)'
            
            % Hamming (7,4)
            H = [1 ,0 ,1 ,0 ,1 ,0 ,1; ...
                0 ,1 ,1 ,0 ,0 ,1 ,1; ...
                0 ,0 ,0 ,1 ,1 ,1 ,1];
            R = [0 ,0 ,1 ,0 ,0 ,0 ,0; ...
                0 ,0 ,0 ,0 ,1 ,0 ,0; ...
                0 ,0 ,0 ,0 ,0 ,1 ,0; ...
                0 ,0 ,0 ,0 ,0 ,0 ,1];
            en = [ 0 0 0 0 0 0 0; eye(7)];
            data_reshaped = reshape(msg,7,length(msg)/7);
            syndrom = mod(H*reshape(data_reshaped, ...
                    [7, length(msg)/7]),2);
            err_loc = 2.^(0:(7-4-1))*syndrom+1;
            bitcorrector = en(err_loc,:).';
            corrected_data = mod((bitcorrector+data_reshaped),2);
            dec     = mod((R*corrected_data),2);
            dec     = reshape(dec,1,[]);
            
        case 'hamm(15,11)'
            
            % Hamming (15,11)
            dec     = decode(msg,15,11,'hamming/binary');
            
        case 'cyclic(15,5)'
            
            % Cyclic Block Code (15,5)
            n           = 15;
            k           = 5;
            genpoly     = cyclpoly(n,k);
            parmat      = cyclgen(n,genpoly);
            trt         = syndtable(parmat);
            clc
            dec         = decode(msg,n,k,'cyclic/binary',genpoly,trt);
            
    end
end