%%
%%%%%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%
Nr = 2;    % num of receiver's antennas (base station)
Nt = 2;    % num of transmitters (user equipments)
M = 2;    % use M-psk modulation
K = 1e5;  % num of symbols transmitted per user
SNR = 0:2:25; 
bit_number = Nt*K*log2(M); 

%%
%%% create a table containing all possible constellation for ML detection %%%
PSK_table = pskmod(0:M-1,M);
for i = 0:power(M,Nt)-1
    tempx = 0;
    tempy = 0;
    for j = 1:Nt
        temp = tempx*tempy';  
        z(j,i+1) = floor((i-temp)/power(M,Nt-j));                            
        tempx(j+1) = z(j,i+1);
        tempy(j+1) = power(M,Nt-j);      
    end   
end
combin_ML = PSK_table(z+1); %every column represents a specific combination
%%
%%% coefficient matrix H, transmitted vector x, reveived vector y %%%
H = randn(Nr, Nt,K)+1i*randn(Nr, Nt,K);
dataIn = randi([0,M-1],Nt,K);
dataMod = pskmod(dataIn,M);
x = dataMod; 
for i = 1:K
    y(:,i)=H(:,:,i)*x(:,i); %%% received signal y without noise added
end
power_rx = trace(y*y')/(Nr*K); %%% signal energy
%%
%%% initialize SER data %%%
ser_ZF = zeros(1,length(SNR));
ser_MMSE = zeros(1,length(SNR));
ser_ML = zeros(1,length(SNR));
%%
%%% simulate detections with different SNR %%%
for i = 1:length(SNR)

    power_n = SNR(i)-10*log10(power_rx); %%% log noise power
    sigma2 = 10^(-power_n/10); %%% noise variance (power)
    noise = (randn(Nr,K)+1i*randn(Nr,K))*sqrt(sigma2/2);
    y_noise = y+noise; %%% y = Hx + n noise added
    
    %%
    %%%%%% ZF detection %%%%%%%%
    %%% x_ZF = ((H'*H)\H')*y %%%
    for j = 1:K
        x_ZF(:,j) = ((H(:,:,j)'*H(:,:,j))\(H(:,:,j)'))*y_noise(:,j);
    end
    dataOut_ZF = pskdemod(x_ZF,M);
    num_error_ZF = sum(dataOut_ZF~=dataIn,'all');
    ser_ZF(i) = num_error_ZF/(Nt*K);
    %%
    %%%%%%%%%%%%% MMSE detection %%%%%%%%%%%%%%
    %%% x_MMSE = ((H'*H + sigma_n2*I)\H')*y %%%
    for j=1:K
        x_MMSE(:,j) = (((H(:,:,j)'*H(:,:,j))+sigma2*diag(ones(1,Nt)))\(H(:,:,j)')*y_noise(:,j));
    end
    dataOut_MMSE = pskdemod(x_MMSE,M);
    num_error_MMSE = sum(dataOut_MMSE~=dataIn,'all');
    ser_MMSE(i) = num_error_MMSE/(Nt*K);
    %%
    %%%%%%%% ML detection %%%%%%%%
    %%% x_ML = argmin |y-Hx|^2 %%%
    state_table = combin_ML;
    for j = 1:K
        distance_square = zeros(1,power(M,Nt));
        for k = 1:power(M,Nt)
            distance_square(1,k) = sum((y_noise(:,j)-H(:,:,j)*state_table(:,k)).*conj((y_noise(:,j)-H(:,:,j)*state_table(:,k))),1);
        end
        [~,I] = min(distance_square);
        x_ML(:,j) = state_table(:, I);
    end
    dataOut_ML = pskdemod(x_ML,M);
    num_error_ML = sum(dataOut_ML~=dataIn,'all');
    ser_ML(i) = num_error_ML/(Nt*K);   
end

%%
%%%%%%%%%%%%%%%%%%%%%%%% display %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
semilogy(SNR,ser_MMSE,'o--','DisplayName','MMSE');
hold on;
semilogy(SNR,ser_ZF,'+--','DisplayName','ZF');
semilogy(SNR,ser_ML,'--.','DisplayName','ML');
grid on
xlabel('SNR[dB]');ylabel('SER');title('MIMO Detection Methods');
legend;