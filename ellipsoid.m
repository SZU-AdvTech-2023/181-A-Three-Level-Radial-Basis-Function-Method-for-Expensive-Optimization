 n=20;
 N0=2*(n+1);
 Xmin=-5.12*ones(1,n);
 Xmax=5.12*ones(1,n);
 LHSsamples= lhsdesign(N0, n);%nomorlized training data  
 datax= repmat(Xmin,N0,1)+(repmat(Xmax,N0,1)-repmat(Xmin,N0,1)).*LHSsamples;
 ackley50=datax;
 filename = 'myE24.mat';
 save(filename,'ackley50');
 %5维第五个（54）  filename='E5d4.mat'      fbest
 %10维第五个（14）  filename='E10d4.mat'      fbest
 %10维第2个（21）  filename='E20d2.mat'      fbest