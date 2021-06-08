function [syms,bps] = mdlt(bits,method)
% Modulate the input bits using the specified method
%   Inputs:
%       bits:   row vector containing bits
%       method: string defining modulation method
% 
%   Options:
%       method: 'bpsk', 'qpsk', '4qam', '16qam'
%
%   Outputs:
%       syms:   modulated symbols
%       bps:    bits per symbol

switch method
    case 'bpsk'
        si      = (-1).^bits;
        syms    = si;
        bps     = 1;
    case 'qpsk'
        sq      = (-1).^bits(1:2:end);
        si      = (-1).^bits(2:2:end).*sq;
        syms    = sqrt(1/2).*(si + 1i.*sq);
        bps     = 2;
    case 'qpskGray'
        sq      = (-1).^bits(1:2:end);
        si      = (-1).^bits(2:2:end);
        syms    = sqrt(1/2).*(si + 1i.*sq);
        bps     = 2;
    case '4qam'
        si      = (-1).^bits(1:2:end);
        sq      = (-1).^bits(2:2:end);
        syms    = sqrt(1/2).*(si + 1i.*sq);
        bps     = 2;
    case '16qam'
        si      = (-1).^bits(1:4:end).*3.^bits(3:4:end);
        sq      = (-1).^bits(2:4:end).*3.^bits(4:4:end);
        syms    = sqrt(1/10)*(si + 1i.*sq);
        bps     = 4;
end
end