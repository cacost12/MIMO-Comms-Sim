function [S,nExtra] = MIMOencode(syms,nt,redun)
% MIMO Encoder
% Inputs: 
%         syms - vector of symbols to be transmitted
%         redun - level of redundnacy in space-time encoding
%         nt - number of transmitters
%
% Outputs: 
%         S: Matrix of tranmitted symbol sequence
%         nExtra: Number of 0s added to Symbol Sequence


% Switch Case for Each Space-Time Coding Option
switch redun
    
    case 'full'
        nExtra = 0;
        S = zeros(nt, length(syms));
        for i=1:nt
            S(i,:) = syms;
        end
        
    case 'none'
        % Calculate the bits sent per transmitter 
        b_per_tx = ceil(length(syms)/nt);
        
        % Calculate the number of zeros to be added to end of sequence
        nExtra = nt*b_per_tx - length(syms);
        
        % Allocate memory for S matrix
        S = zeros(nt, b_per_tx);
        
        % Populate the S matrix
        for i=1:nt
            if i~=nt
                S(i,:) = syms((i-1)*b_per_tx + 1:b_per_tx*i);
            else
                S(i,1:b_per_tx - nExtra) = syms((i-1)*b_per_tx + 1:end);
            end
        end
end

