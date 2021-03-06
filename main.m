%% EEE 455: Communication Systems
% Honors Lab: MIMO Systems
% Author: Colton Acosta

% Clear workspace
clear; clc; format long; format compact;

% Set figure properties
prefs();

%% Specifications to Consider 

% SNR Range 
snr_vec_dB  = [-5 0 5 10 15 20 25];
snr_vec     = 10.^(snr_vec_dB./10);
n_snr       = length(snr_vec_dB);

% Number of Recievers
nr = [2, 3, 4];

% Number of Transmitters
nt = [2, 3, 4];

%% Basic Flat-Fading Communications Toolchain

% Modulation Type
modType = 'qpskGray';

% Forward Error Correcting Code
fecType = 'hamm(7,4)';

% SNR Range 
%snr_vec_dB  = [-5 0 5 10 15 20 25];
%snr_vec     = 10.^(snr_vec_dB./10);
%n_snr       = length(snr_vec_dB);
snr_dB = 10;
snr = 10^(snr_dB/10);

% Generate Training and signal bits
nBits = 4^8; 
data  = round(rand(1,nBits));

% Encode Data Bits using FEC
enc = encd(data, fecType);
nBits = length(enc);

% Modulate training and data 
[symsData,~]    = mdlt(enc,modType);
symsAll         =  symsData;

% Plot IQ of Modulated Symbols
plotIQ(real(symsAll), imag(symsAll))
title('IQ Plot of SISO QPSK Modulated Data')

% Filter symbols
beta        = 0.25;
span        = 16;
sps         = 1;
psf         = rcosdesign(beta,span,sps);
symsAllFilt = conv(psf,symsAll);

% Trim Filtered Symbols 
nTrim = length(symsAllFilt) - length(symsAll);
symsAllFilt = symsAllFilt(nTrim/2 + 1:length(symsAllFilt) - nTrim/2);
 
% Plot IQ of filtered symbols
plotIQ(real(symsAllFilt), imag(symsAllFilt))
title('IQ Plot of SISO Filtered Symbols')

% Export symbols
tx          = symsAllFilt;
    
% Define transmitter variables
fc      = 915e6;
B       = 10e6;

% Normalize signal power
pSig    = sum(abs(tx).^2)/length(tx);
tx      = tx./sqrt(abs(pSig));

% Generate additive noise
n       = length(tx);
u       = 0;
sig2    = 1;
sigma   = sqrt(sig2);
re      = u + sigma.*randn(1,n);
quad    = 1i.*(u + sigma.*randn(1,n));
v       = (re + quad)./sqrt(2);

% Normalize noise power
pN      = sum(abs(v).^2)/length(tx);
v       = v./sqrt(abs(pN));

% Complex attenuation
amp     = sqrt(snr);
phs     = 2*pi*rand(1);
rx      = amp.*tx.*exp(1i*phs);

% Plot IQ of Attenuated signal
plotIQ(real(rx), imag(rx))
title('IQ Plot of SISO Attenuated Symbols')

% Verify SNR
pSig    = sum(abs(rx).^2)/length(rx);
pN      = sum(abs(v).^2)/length(tx);
snr     = pSig/(pN);
snrdB   = 10.*log10(abs(snr));

% Add noise
rxN     = rx + v;

% Plot IQ of Noisy Symbols
plotIQ(real(rxN), imag(rxN))
title('IQ Plot of SISO Noisy and Attenuated Symbols')

% Acquisition
rxFilt      = conv(psf,rxN);
rxFilt = rxFilt(nTrim/2 + 1:length(rxFilt) - nTrim/2);
rxAcq       = rxFilt;

% Equalization;
rxEq    = rxAcq.*exp(-1i*phs);

% Plot IQ of Equalized Symbols
plotIQ(real(rxEq), imag(rxEq))
title('IQ Plot of SISO Equalized Symbols')

% Demodulation
rxBits  = demdlt(rxEq,modType);
    
% Decode
rxTrim  = rxBits;
dec     = decd(rxTrim, fecType);
    
% Calculate bit errors
if mod(length(dec),2) == 1
    dec     = dec(1:end-1);
end

len     = min(length(data),length(dec));
data    = data(1:len);
dec     = dec(1:len);
syms    = reshape(dec,[],2);
ref     = reshape(data,[],2);
err     = abs(syms - ref);

% Look for erros in symbols
symFlag = max(err.').';

% Compute SER =/= BER
ser     = sum(symFlag)./numel(symFlag);
ber     = sum(err(:))./numel(err);


%% MIMO Implementation 

% Calculate the channel matrix
nt = 3; 
nr = 4;
H_amp = rand(nr, nt);
H_phase = rand(nr, nt);
H = H_amp.*exp(1i*H_phase);

% Generate Training and signal bits
nBits = 4^8; 
data  = round(rand(1,nBits));
nTrain = 256;
train = round(rand(nt, nTrain));

% Encode Data Bits using FEC
enc = encd(data, fecType);
nBits = length(enc);

% Modulate training and data 
[symsData,~]    = mdlt(enc,modType);
symsTrain = zeros(nt, nTrain/2);
for i=1:nt
    symsTrain(i,:) = mdlt(train(i,:), modType);
end


% Encode Symbols with full redundancy 
[S, nExtra] = MIMOencode(symsData, nt, 'full');

% Generate additive noise
u       = 0;
sig2    = 1;
sigma   = sqrt(sig2);
re      = u + sigma.*randn(nr,length(S));
quad    = 1i.*(u + sigma.*randn(nr,length(S)));
N       = (re + quad)./sqrt(2);
reTrain = u + sigma.*randn(nr,length(symsTrain));
quadTrain    = 1i.*(u + sigma.*randn(nr,length(symsTrain)));
Ntrain       = (reTrain + quadTrain)./sqrt(2);

% Scale Noise
F = 1;
N = N*F;
Ntrain = Ntrain*F;

% Send Signal through MIMO channel
Z = H*S + N;

% Calculate Filter From training data
Ztrain = H*symsTrain + Ntrain;
W = MIMOfilter(symsTrain, Ztrain);

% Apply filter to Signal
S_hat = (W')*Z;

% Demodulate MIMO Signals
syms = MIMOdecode(S_hat, 'full');

% Demodulation
rxBits  = demdlt(syms, modType);

% Decode
rxTrim  = rxBits;
dec     = decd(rxTrim, fecType);

% Calculate bit errors
if mod(length(dec),2) == 1
    dec     = dec(1:end-1);
end

len     = min(length(data),length(dec));
data    = data(1:len);
dec     = dec(1:len);
syms_err    = reshape(dec,[],2);
ref     = reshape(data,[],2);
err     = abs(syms_err - ref);

% Look for erros in symbols
symFlag = max(err.').';

% Compute SER =/= BER
ser     = sum(symFlag)./numel(symFlag);
ber     = sum(err(:))./numel(err);




