%%
Nr = 64;    % num of receiver's antennas (base station)
Nt = 8;    % num of transmitters (user equipments)
M = 64;    % use M-qam modulation
K = 1e5;  % num of symbols transmitted per user
SNR = 5:15; 
bit_number = Nt*K*log2(M); 
NS_order =3;
NI_order =3;
GS_order =3;
CG_order =3;
Ja_order =4;
%%
%%% coefficient matrix H, transmitted vector x, reveived vector y %%%
H = sqrt(0.5)*(randn(Nr, Nt,K)+1i*randn(Nr, Nt,K));
dataIn = randi([0,M-1],Nt,K);
dataMod = qammod(dataIn,M);
x = dataMod; 
for i = 1:K
    y(:,i)=H(:,:,i)*x(:,i); %%% received signal y without noise added
end
power_rx = mean(mean(abs(x).^2)); %%% signal energy
%%
%%% initialize SER data %%%
ser_NI = zeros(1,length(SNR));
ser_NS = zeros(1,length(SNR));
ser_GS = zeros(1,length(SNR));
ser_CG = zeros(1,length(SNR));
ser_Ja = zeros(1,length(SNR));
%ser_MMSE = zeros(1,length(SNR));
%%
%%% simulate detections with different SNR %%%
for i = 1:length(SNR)

    log_noise = SNR(i)-10*log10(power_rx); %%% -10log10(Noise)
    sigma2 = 10^(-log_noise/10); %%% noise variance (power)
    noise = (randn(Nr,K)+1i*randn(Nr,K))*sqrt(sigma2/2);
    y_noise = y+noise; %%% y = Hx + n noise added
    %%%%% x estimation using different approximate methods %%%%%
    for j=1:K
        A = H(:,:,j)'*H(:,:,j)+sigma2*diag(ones(1,Nt));
        b = (H(:,:,j)')*y_noise(:,j);
%        x_MMSE(:,j) = A\b;
        x_NS(:,j) = Neumann(A,b,NS_order); %%% approximate inverse by Neumann Series
        x_NI(:,j) = NI(A,b,NI_order,Nt); %%% approximate inverse by Newton Iteration
        x_GS(:,j) = Gauss(A,b,GS_order); %%% Gauss-Seidel iteration
        x_CG(:,j) = CG(A,b,CG_order,Nt); %%% Conjugate Gradient
        x_Ja(:,j) = Jacobi(A,b,Ja_order); %%% Jacobi iterative method
    end
    dataOut_NS = qamdemod(x_NS,M);
    dataOut_NI = qamdemod(x_NI,M);
    dataOut_GS = qamdemod(x_GS,M);
    dataOut_CG = qamdemod(x_CG,M);
    dataOut_Ja = qamdemod(x_Ja,M);
%    dataOut_MMSE = qamdemod(x_MMSE,M);
    num_error_NS = sum(dataOut_NS~=dataIn,'all');
    num_error_NI = sum(dataOut_NI~=dataIn,'all');
    num_error_GS = sum(dataOut_GS~=dataIn,'all');
    num_error_CG = sum(dataOut_CG~=dataIn,'all');
    num_error_Ja = sum(dataOut_Ja~=dataIn,'all');
%    num_error_MMSE = sum(dataOut_MMSE~=dataIn,'all');
    ser_NS(i) = num_error_NS/(Nt*K);
    ser_NI(i) = num_error_NI/(Nt*K);
    ser_GS(i) = num_error_GS/(Nt*K);
    ser_CG(i) = num_error_CG/(Nt*K);
    ser_Ja(i) = num_error_Ja/(Nt*K);
%    ser_MMSE(i) = num_error_MMSE/(Nt*K);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%% display %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
semilogy(SNR,ser_NS,'o-','DisplayName','Neumann Series');
hold on;
semilogy(SNR,ser_NI,'x-','DisplayName','Newton Iteration');
semilogy(SNR,ser_GS,'^-','DisplayName','Gauss Seidel');
semilogy(SNR,ser_Ja,'d-','DisplayName','Jacobi method');
semilogy(SNR,ser_CG,'s-','DisplayName','Conjugate Gradient');
%semilogy(SNR,ser_MMSE,'k-p','DisplayName','MMSE');
grid on
xlabel('SNR[dB]');ylabel('SER');title('MIMO Detection(N×K=64×8)');
%set(gca,'YLim',[1e-6 1e-0]);
legend;
%%
%%%%%Neumann Series approximation%%%%%
function[x_hat] = Neumann(A,b,iter)
D = diag(diag(A));
E = A - D;
Ainv = 0; %%% initialize A inverse
for i = 0:iter
    Ainv = Ainv + ((-inv(D)*E)^i) * inv(D);
end
x_hat = Ainv * b;
end
%%
%%%%% Newton Iteration method %%%%%%
function[x_hat] = NI(A,b,iter,Nt)
D = diag(diag(A));
Ainv = inv(D); %%% initialize A0 inverse
for i = 1:iter
    Ainv = Ainv*(2*diag(ones(1,Nt)) - A*Ainv);
end
x_hat = Ainv * b;
end
%%
%%%%% Gauss-Seidel method %%%%%
function[x_hat] = Gauss(A,b,iter)
D = diag(diag(A));
E = -triu(A,1);
F = -tril(A,-1);
x_hat = diag(inv(D));
for i = 1:iter
    x_hat = (D-E)\(F*x_hat+b);
end
end
%%
%%%%% Jacobi method %%%%%
function [x_hat] = Jacobi(A,b,iter)
D = diag(diag(A));
x_hat = D\b;
for i = 1:iter
    x_hat = D\(b+(D-A)*x_hat);
end
end
%%
%%%%% Conjugate Gradient %%%%%
function [x_hat] = CG(A,b,iter,Nt)
r = b;
p = r;
v = zeros(Nt,1);
for k = 1:iter
    e = A*p;
    alpha  = norm(r)^2/(p'*e);
    v = v+alpha*p;
    new_r = r-alpha*e;
    beta = norm(new_r)^2/norm(r)^2;
    p = new_r+beta*p;
    r = new_r;
end
x_hat = v;
end