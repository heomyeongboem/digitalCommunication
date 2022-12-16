clear all;
close all;
A = 1; %증폭기
f = 10; %주기
t = 0:0.01:0.3;%시간의 변화를 나타냄 0초부터 0.3초까지 0.01초로 단위로 샘플링
N = 10000; %랜덤 프로세스 갯수
theta = 2 * pi * rand(N,1); %0부터 2pi 사이의 유니폼 분포를 만든다.
X = zeros(N,length(t)); % 7개 행과 31개의 열에서 0을 가지는 행렬
for i = 1:N X(i,:) = A * cos(2 * pi * f * t + theta(i)); end % X의 i행 0열부터 31열까지에 이 함수의 0부터 31까지 만든 값을 넣겠다
%시간 오래걸려서 뺌 
%{
figure,
for i = 1:N
    subplot(N,1,i),plot(t,X(i,:)); %i 행의 0열부터 31열까지의 값을 그려라
    if i == N
        xlabel('time');
    end
    axis([0 0.3 -1.2 1.2]);
    grid;
end
%}

[N,T] = size(X); %[행,열] = size(분포)
t = 0:0.01:0.3;
mean_values = zeros(1,length(t));
for i = 1:T mean_values(i) = sum(X(:,i))/N; end %즉, 모든행에서 열단위로 더한 값을 총 갯수로 나눠라 => 특정 시간에 대한 평균 값// 샘플의 갯수가 많아지면 많아질수록 
%sample 이 많아지면 많아질수록 랜덤 variable의 continuous 해지기 때문에 평균이 0에 가까워지는 것을 볼 수 있다.
auto_corr = zeros(1,(length(t) -1)/2); %15개만 만든다.
for i = 0:T/2-1 %matlab은 원래 1부터 시작이다. 
    auto_corr(i + 1) = sum(X(:,1).* X(:,1 + i))/N; % auto_corr = X(t) * X(t - 타우)의 평균 이잖아 그래서 우리는 처음지점을 기준으로 시간이 지나면 지날수록 
    %얼마나 닮아있는지를 판단해준다.
end
figure,plot(t,mean_values);
xlabel('t','fontsize',14);
ylabel('t','fontsize',14);
grid;
axis([0 0.3 -1.2 1.2]);
figure,plot([0:T/2-1]*0.01,auto_corr);
xlabel('t','fontsize',14);
ylabel('t','fontsize',14);
grid;
axis([0 0.3/2 -0.7 0.7]);





