%p.34 uniform 분포를 이용한 central limit theorem 
%made in MyeongBoem Heo
clear all;
close all;

L = 1000000;
%여기서 z1,z2,...z5는 모두 랜덤변수로 독립적이다.
%또한 모두 -1 에서 1 사이의 범위 값을 가지는 유니폼 분포이므로 모두들 확률 밀도 함수가 같다.
%이 랜덤변수들을 다 더한값의 분포를 알고 싶다.
z1 = -1 + (1 + 1)*rand(L,1);
z2 = -1 + (1 + 1)*rand(L,1);
z3 = -1 + (1 + 1)*rand(L,1);
z4 = -1 + (1 + 1)*rand(L,1);
z5 = -1 + (1 + 1)*rand(L,1);
Z = z1 + z2 + z3 + z4 + z5;

subplot(2,1,1),plot(Z(1:100));
grid;
axis([0 100 -5 5])

[A B] = hist(Z,100); %히스토그램에서 [갯수, 도수] = hist(분포,샘플링 간격)
area = (B(2) - B(1)) * sum(A);
pdf = A/area;
subplot(2,1,2),plot(B,pdf); % x축은 도수 , y축은 확률 밀도 함수
xlabel('z','fontsize',14);
ylabel('f_Z(z)','fontsize',14);
grid;
axis([-5 5 0 1]);
%즉 독립적인 유니폼 분포(잡음 분포)를 다 더하게 되면 가우시안 분포를 띄게 되는 것을 알 수 있다.  