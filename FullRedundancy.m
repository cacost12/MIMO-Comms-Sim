%% EEE 455: Communication Systems
% Honors Lab: MIMO Systems
% Fully Redundant MIMO System
% Author: Colton Acosta

% Clear workspace
clear; clc; format long; format compact;

% Set figure properties
prefs();

%% MIMO Settings 

% Number of transmitters and recievers
nt = 3; 
nr = 4;

% Channel Matrix 
H_amp = rand(nr, nt);
H_phase = rand(nr, nt);
H = H_amp.*exp(1i*H_phase);

%% Generate, Modulate, and Filter Data

% Modulation Type
modType = 'qpskGray';

% Forward Error Correcting Code
fecType = 'hamm(7,4)';

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
symsAll         =  symsData;

% Plot IQ of Modulated Symbols
plotIQ(real(symsAll), imag(symsAll))
title('IQ Plot of QPSK Modulated Data with Hamm(7,4) FEC')

% Filter symbols
beta        = 0.25;
span        = 16;
sps         = 1;
psf         = rcosdesign(beta,span,sps);
symsAllFilt = conv(psf,symsAll);
symsTrainFilt = zeros(size(symsTrain));
for i=1:nTrain
    symsTrainFilt(i,:) = conv(psf, symsTrain(i,:));
end

% Trim Filtered Symbols 
nTrim = length(symsAllFilt) - length(symsAll);
symsAllFilt = symsAllFilt(nTrim/2 + 1:length(symsAllFilt) - nTrim/2);
 
% Plot IQ of filtered symbols
plotIQ(real(symsAllFilt), imag(symsAllFilt))
title('IQ Plot of Filtered Symbols')

% Export symbols
tx          = symsAllFilt;

% Normalize signal power
pSig    = sum(abs(tx).^2)/length(tx);
tx      = tx./sqrt(abs(pSig));

%% Noise and Capacity

% SISO Noise 
n_SISO       = length(tx);
u_SISO       = 0;
sig2_SISO    = 1;
sigma_SISO   = sqrt(sig2_SISO);
re_SISO      = u_SISO + sigma_SISO.*randn(1,n_SISO);
quad_SISO    = 1i.*(u_SISO + sigma_SISO.*randn(1,n_SISO));
v_SISO       = (re_SISO + quad_SISO)./sqrt(2);

% Normalize noise power
pN_SISO      = sum(abs(v_SISO).^2)/length(tx);
v_SISO       = v_SISO./sqrt(abs(pN_SISO));

% Generate Noise Matrix
u_MIMO       = 0;
sig2_MIMO    = 1;
sigma_MIMO   = sqrt(sig2_MIMO);
re_MIMO      = u_MIMO + sigma_MIMO.*randn(nr,nBits);
quad_MIMO    = 1i.*(u_MIMO + sigma_MIMO.*randn(nr, nBits));
N       = (re_MIMO + quad_MIMO)./sqrt(2);
reTrain_MIMO = u_MIMO + sigma_MIMO.*randn(nr,length(symsTrain));
quadTrain_MIMO    = 1i.*(u_MIMO + sigma_MIMO.*randn(nr,length(symsTrain)));
Ntrain       = (reTrain_MIMO + quadTrain_MIMO)./sqrt(2);