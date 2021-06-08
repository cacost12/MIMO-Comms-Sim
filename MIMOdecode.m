function [syms, E] = MIMOdecode(S_hat,redun)
% MIMO Decode: Decode Space-Time coding
% Inputs: 
%        S_hat - Estimate of transmitted sequence
%        redun - Amount of redundancy in Space-Time coding
% 
% Outputs: 
%         syms - transmitted sequence of symbols

% Switch Case for Each Space-Time Coding Option
switch redun
    
    case 'full'
        % Compute the energy matrix off-diagonal terms
        nt = length(S_hat(:,1)); % number of transmitters
        E = zeros(nt,nt);
        for i=1:nt-1
            for j=i+1:nt
                E(i,j) = sum(S_hat(i,:).*S_hat(j,:));
            end
        end
        
        % Find the maximum Entry
        [~, rowNums] = myMatrixMax(E);
        
        % Average the two corresponding rows 
        syms = 0.5*(S_hat(rowNums(1),:) + S_hat(rowNums(2),:));
        
    case 'none'
        syms = 0;
        E = 0;
        
end

