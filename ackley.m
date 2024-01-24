 n=20;
 N0=2*(n+1);
 Xmin=-32.768*ones(1,n);
 Xmax=32.768*ones(1,n);
 LHSsamples= lhsdesign(N0, n);%nomorlized training data       
 datax= repmat(Xmin,N0,1)+(repmat(Xmax,N0,1)-repmat(Xmin,N0,1)).*LHSsamples;
 ackley50=datax;
 filename = 'myA24.mat';
 save(filename,'ackley50');
 %myA50.mat~myA54.mat   ackley50  5维的5个初始化矩阵
 %myA10.mat~myA14.mat  ackley50  10维的5个初始化矩阵
 %myA20.mat~myA24.mat  ackley50  20维的5个初始化矩阵