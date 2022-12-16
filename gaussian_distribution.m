clear all;
close all;

L = 1000000;
z = randn(1,L); %정규 분포 1 * L 만큼 
subplot(2,1,1),plot(z(1:100));
grid;
axis([0 100 -5 5])

[A B] = hist(z,100); %히스토그램에서 [갯수, 도수] = hist(분포,샘플링 간격)
area = (B(2) - B(1)) * sum(A);
pdf = A/area;
subplot(2,1,2),plot(B,pdf); % x축은 도수 , y축은 확률 밀도 함수
xlabel('z','fontsize',14);
ylabel('f_Z(z)','fontsize',14);
grid;
axis([-5 5 0 1]);
