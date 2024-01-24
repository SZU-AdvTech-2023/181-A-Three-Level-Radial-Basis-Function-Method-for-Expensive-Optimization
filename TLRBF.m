%% A Three-Level Radial Basis Function Method for Expensive Optimization
%% IEEE Transactions on Cybernetics
%% Author: Genghui Li (li_genghui@126.com, genghuili-c@my.cityu.edu.hk),
%% City University of Hong Kong 
clc;
clear;
tic
format short e
warning off
%% The dimension of the problem
n=20;
%% The number of total running times
totaltime=1;
%% RBF parameters
Basisfunction='MQ';%核函数是 多二次基函数
c=0.8;
%% Record the historical best result of all problems 
Fbest=[];
%% Set the maximum number of function evalutions 
switch n
    case 5
        maxFES=200;
    case 10 
        maxFES=300;
    case 20
        maxFES=400;
end
%% Parameters of TLRBF
m=8000*n;
alpha=0.4;
if n<=10
   L1=50;L2=40;
else
   L1=100;L2=80;
end
Deltal_S=10e-3*sqrt(n);
Deltal_L=10e-4*sqrt(n);
 
%% Optimize each problem
for problem=3:3
   %% Set the lower and upper bound, and the name of the problem
    switch problem
        case 1
        Xmin=-5.12*ones(1,n);
        Xmax=5.12*ones(1,n);
        name='Ellipsoid';
        case 2
        Xmin=-2.048*ones(1,n);
        Xmax=2.048*ones(1,n);
        name='Rosenbrock';   
        case 3
        Xmin=-32.768*ones(1,n);
        Xmax=32.768*ones(1,n);
        name='Ackley';
        case 4
        Xmin=-600*ones(1,n);
        Xmax=600*ones(1,n);
        name='Griewank';
        case 5
        Xmin=-5*ones(1,n);
        Xmax=5*ones(1,n);
        name='Rastrigin';
    end
    %% Record the historical best result for each problem  
    fbest=[];
    for time=1:totaltime   
       %% The database save all evaluated solutions 
        datax=[]; % save the solution
        datay=[]; % save the objective function value
       %% The number of function evlautions 
        FES=0;
       %% The number of initial solutions 
        N0=2*(n+1);
        %LHSsamples= lhsdesign(N0, n);%nomorlized training data       
        %datax= repmat(Xmin,N0,1)+(repmat(Xmax,N0,1)-repmat(Xmin,N0,1)).*LHSsamples;
        %datax=lhsdesign(N0,n).*(ones(N0,1)*(Xmax-Xmin))+ones(N0,1)*Xmin;
        load('myA21.mat');
        datax = ackley50;
       %% Evaluate the initial solutions
        for i=1:N0
            fit_infill = expensive_benchmark_func(datax(i,:),problem);
            datay=[datay; fit_infill];
            FES=FES+1;
            besty=min(datay);
            fbest(FES,time)=besty;         
        end      
       %% Optimization loop
        while FES<maxFES           
           %% Global search
            if FES<maxFES    
               %% Train the global RBF model
                options= srgtsRBFSetOptions(datax, datay,@rbf_build,0,Basisfunction,c,0);
                [surrogate, state] = srgtsRBFFit(options);
               %% Global search: infill denotes the solution generated by the global search
                infill=GlobalSearch(Xmin,Xmax,datax,surrogate,m,alpha,n);              
                fit_infill=expensive_benchmark_func(infill,problem);
               %% Record the number of function evaluations
                FES=FES+1;
               %% Update the best objective function value: besty
                if fit_infill<besty
                    besty=fit_infill;                      
                end 
               %% Record the best result             
                fbest(FES,time)=besty;  
               %% Update the data base 
                datay=[datay; fit_infill];
                datax=[datax;infill];                         
            end
             
           %% Subregion search
            if FES<maxFES 
              %% no_points denotes the number of points that have been evalauted. 
                no_points=FES;
              %% Conduct subregion search to generate new solution: infill 
                infill=SubregionSearch(datax,datay,L1, L2,Basisfunction,c,n,no_points);
              %% Calculate the distance between the new solution and the evaluated solutions
                distance=pdist2(datax,infill);
                if min(distance)>Deltal_S     
                 %% Evalaute the new solution
                   fit_infill=expensive_benchmark_func(infill,problem);
                 %% Record the number of function evaluations
                   FES=FES+1;
                 %% Update the best objective function value: besty
                   if fit_infill<besty
                        besty=fit_infill; 
                   end  
                 %% Record the best result 
                   fbest(FES,time)=besty; 
                 %% Update the data base 
                   datay=[datay; fit_infill];
                   datax=[datax;infill];           
                end                
            end 
            
           %% Local search stage          
            if FES<maxFES 
              %% Set the number of neighbors 
                k=min(2*n,FES-1); 
              %% Conduct subregion search to generate new solution: infill 
                infill=LocalSearch(datax,datay,Basisfunction,c,n,k);
              %% Calculate the distance between the new solution and the evaluated solutions
                distance=pdist2(datax,infill);
                if min(distance)>Deltal_L    
                 %% Evalaute the new solution
                   fit_infill=expensive_benchmark_func(infill,problem);
                 %% Record the number of function evaluations
                   FES=FES+1;                  
                 %% Update the best objective function value: besty
                   if fit_infill<besty
                        besty=fit_infill; 
                   end  
                 %% Record the best result 
                   fbest(FES,time)=besty; 
                 %% Update the database 
                   datay=[datay; fit_infill];
                   datax=[datax;infill];                                     
                end                
            end 
        end
       %% Record the final result of each problem in each time
        outcome(time,problem)=besty        
    end 
    %% Record all historical results for all problems
    Fbest{problem}=fbest
end
mean(outcome)
std(outcome)
%plot(fbest(:,1),datay(:,1));
%points=[1,sum(outcome(:,1))/totaltime;2,sum(outcome(:,2))/totaltime;3,sum(outcome(:,3))/totaltime;4,sum(outcome(:,4))/totaltime;5,sum(outcome(:,5))/totaltime]
%plot(points(:,1),points(:,2));
%for i = 1:length(points)
%   hold on; % 保持当前图形
 %   plot(points(i,1), points(i,2), 'k^', 'MarkerSize', 10); % 使用黑色三角形标记点
 %   hold off; % 关闭保持图形
%end
%title('五个函数上运行的均值');
%xlabel('函数类型');
%ylabel('最终结果');
%grid on;

%x=1:1:maxFES;
%plot(x,fbest);
%hold on;
%xlabel('FES');
%ylabel('TLRBF Fitness value');
%title('Ackley');

