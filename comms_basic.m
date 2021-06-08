function [ser, ber] = comms_basic(nTrain, nBits, modType, fecType, snr, plt)

    % Generate random bits
    train       = round(rand(1,nTrain));
    data        = round(rand(1,nBits));
    
    % Encode data bits
    enc         = encd(data,fecType);
    nBits       = length(enc);

    % Modulate training and data 
    [symsTrn,~]     = mdlt(train,modType);
    [symsData,~]    = mdlt(enc,modType);
    symsAll         = [symsTrn symsData];
    
    % Demodulate symbols
    bitsTrnDmod     = demdlt(symsTrn,modType);
    bitsDatDmod     = demdlt(symsData,modType);
    checkTrn        = sum(train-bitsTrnDmod);
    checkDat        = sum(enc-bitsDatDmod);
    err             = checkTrn + checkDat;
    
    % Filter symbols
    beta        = 0.25;
    span        = 16;
    sps         = 1;
    psf         = rcosdesign(beta,span,sps);
    symsTrnFilt = conv(psf,symsTrn);
    symsTrnFilt = symsTrnFilt(1+span/2:end-span/2);
    symsAllFilt = conv(psf,symsAll);

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

    % Verify SNR
    pSig    = sum(abs(rx).^2)/length(rx);
    pN      = sum(abs(v).^2)/length(tx);
    snr     = pSig/(pN);
    snrdB   = 10.*log10(abs(snr));

    % Time delay
    tau     = 3e-6;
    tauSamp = round(tau*B);
    rx      = [zeros(1,tauSamp) rx];

    % Add noise
    v       = [zeros(1,tauSamp) v];
    rxN     = rx + v;

    % Acquisition
    rxFilt      = conv(psf,rxN);
    [xc, lags]  = xcorr(rxFilt,symsTrnFilt);
    [mx,loc]    = max(xc);
    ndx         = lags(loc);
    rxAcq       = rxFilt(1+ndx:ndx+length(symsAllFilt));

    % Equalization
    phs     = angle(mx);
    rxEq    = rxAcq.*exp(-1i*phs);

    % Demodulation
    rxBits  = demdlt(rxEq,modType);
    
    % Decode
    rxTrim  = rxBits(1+nTrain:nTrain+nBits);
    dec     = decd(rxTrim, fecType);
    dec     = dec(1:end-1);
    
    % Compute symbol and bit errors
    switch modType 
        case 'bpsk'

            % Calculate BER = SER
            if mod(length(dec),2) == 1
                dec     = dec(1:end-1);
            end
            len     = length(dec);
            data    = data(1:len);
            err     = abs(dec - data);
            ber     = sum(err)/length(err);
            ser     = ber;

        case {'qpsk','qpskGray'}

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

    end
    
    % Generate plots
    if plt == 1
       
        % Plot IQ, raw
        plotIQ(real(symsAll),imag(symsAll));
        axis([-1.5,1.5,-1.5,1.5])
        title('IQ, QPSK')
        
        % Plot IQ, filtered
        plotIQ(real(symsAllFilt),imag(symsAllFilt));
        axis([-1.5,1.5,-1.5,1.5])
        title('IQ, QPSK, Filtered')
        
        % Plot noisy reception
        mx      = max(abs(rxN));
        rxN     = rxN./mx;
        plotIQ(real(rxN),imag(rxN));
        axis([-1.5,1.5,-1.5,1.5])
        title('IQ, QPSK, Noisy')
        
        % Plot IQ, equalized
        plotIQ(real(rxEq),imag(rxEq));
        axis([-1.5,1.5,-1.5,1.5])
        title('IQ, QPSK, Equalized')
        
    end
end

