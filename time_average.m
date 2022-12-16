clear all;
close all;
%% time domain이 0 ~ 800, Amplitude가 0~ 2
%data = importdata("Fig8_16_signal.dat");
%plot(data);
%%
t = 1:800;
s = tdfread("Fig8_16_signal.dat"); %구조체형 배열로 가져옴
T = struct2table(s);%구조체형 배열을 테이블로 변환
sample = table2array(T); %테이블을 배열로 변환 
sample = reshape(sample,[1,800]);%1*800배열로 변환

sampling_count = 100;
sampling_time_interval = 8;
X = zeros(sampling_count,1);% 40 행 20열 
for i = 1:sampling_count
    X(i,1:sampling_time_interval) = sample(1,(i - 1) * sampling_time_interval + 1 :(i - 1) * sampling_time_interval + sampling_time_interval);%20개씩 샘플링 총 40묶음
end

%%time average 
[N,T] = size(X); % 

t = 1:T ;%20개의 간격 시간 이고 샘플이 40개임 
mean_val = zeros(1,length(t));

%%ensemble average E{X(t)}
for i = 1:T
    mean_val(i) = sum(X(:,i))/N;
end

auto_corr = zeros(1,length(t));
%%time average autocorrelation
for i = 0:T-1
    auto_corr(i + 1) = sum(X(:,1).*X(:,1 + i))/N; %E{X(t)* X(t-타우)}
end

%%ㅈ망
negative_auto_corr = fliplr(auto_corr);
print_auto_corr = horzcat(negative_auto_corr,auto_corr);

figure,plot(t,mean_val);
xlabel('t','fontsize',14);
ylabel('t','fontsize',14);
grid;
axis([0 20 -20 20]);

figure,plot(1:2*T,print_auto_corr);
xlabel('t','fontsize',14);
ylabel('t','fontsize',14);
grid;
axis([0 40 -20 30]);
%시간 간격을 줄여서 시간에 대한 샘플링 갯수를 늘리면 늘릴수록 time average가 ensemble average와 가까워지는것을
%볼 수 있다. 즉, 시간에 대해 샘플링 갯수를 늘리면 늘릴수록 ergotic 해지는 것을 볼 수 있다.








