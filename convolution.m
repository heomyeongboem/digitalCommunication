X = [1 2 0.5 1 0 1];
H = [1.5 2.5 3 2 1 0.5 0.1];
result = conv_new(H,X);

subplot(1,3,1)
plot(1:length(X),X,'bx');
xlabel("t");
ylabel("x(t)");
axis equal;

subplot(1,3,2);
plot(1:length(H),H,'kx');
xlabel("t");
ylabel("h(t)");
axis equal;

subplot(1,3,3);
plot (1:length(result),result,'ro');
xlabel("t");
ylabel("y(t)");
axis equal;

%filename:conv_new.m
function y= conv_new(h,x);
length_h=length(h);
length_x=length(x);
y_temp=zeros(length_x,length_h+length_x-1);
for i=1:length_x
y_temp(i,:)=[zeros(1,i-1) x(i)*h zeros(1,length_x-1-(i-1))];
end
for i=1:length_x+length_h-1
y(i)=sum(y_temp(:,i));
end
end
