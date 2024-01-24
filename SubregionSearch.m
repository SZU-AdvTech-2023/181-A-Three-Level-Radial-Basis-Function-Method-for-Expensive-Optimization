function newpoint=SubregionSearch(datax,datay,L1, L2,Basisfunction,c,n,no_points)
if no_points<=L1
    %RBF
    %options= srgtsRBFSetOptions(datax, datay,@rbf_build,0,Basisfunction,c,0);
    %[surrogate, ~] = srgtsRBFFit(options);   

    %KRG
    options = srgtsKRGSetOptions(datax, datay);
    [surrogate,~] = srgtsKRGFit(options);

    tempdatax=datax;
else
    Csize=1+ceil((no_points-L1)/L2);
    %模糊聚类
    %normalized_datax=mapminmax(datax',0,1)';
    %[~,u,~]=myfcm(normalized_datax,Csize);
    %u=u';
    %[~,sortid]=sort(u,'descend');
    %C=[];

    %k近邻
    [C, ~] = knnsearch(datax, datax, 'K',Csize);%
    clusters = cell(Csize, 1);
    for i = 1:size(datax, 1)
        distance = min(C(i,:));
        cluster_id = find(C(i,:) == distance)
        clusters{cluster_id} = [clusters{cluster_id}; datax(i, :)];
    end%

    mper=[];

    hold on
    for k=1:Csize
        %C{k}=datax(sortid(1:L1,k),:);
        %Y{k}=datay(sortid(1:L1,k),1);

        %k近邻
        matrix_array=cellfun(@(x) x,clusters, 'UniformOutput', false);
        B=matrix_array{k};
        y_predrbf = ackley(B);
        %y_predrbf = ellipsoid(B);
        %y_predrbf =rosenbrock(B);
        %y_predrbf=griewank(B);
        %y_predrbf=rastrigin(B);

        %mper(k)=mean(Y{k});
        mper(k)=mean(y_predrbf);

        %RBF
        %options= srgtsRBFSetOptions(C{k}, Y{k},@rbf_build,0,Basisfunction,c,0);
        %模糊聚类
        %options= srgtsRBFSetOptions(B,y_predrbf,@rbf_build,0,Basisfunction,c,0);
        %k近邻

        %[Surrogate{k}, State{k}] = srgtsRBFFit(options);
        %surrogate=Surrogate{k};
        
        %KRG
        options = srgtsKRGSetOptions(B,y_predrbf);
        [Surrogate{k},~] = srgtsKRGFit(options);
        surrogate=Surrogate{k};
        
        
    end
    [~,sortid]=sort(mper,'descend');
    pro=sortid/Csize;
    sid=randi([1,Csize],1);
    while rand>pro(sid)
        sid=randi([1,Csize],1);
    end   
    %tempdatax=C{sid};
    %模糊聚类
    tempdatax=C(sid);
    %k近邻
    surrogate=Surrogate{sid};     
end
      lu=[min(tempdatax);max(tempdatax)];  
      newpoint=JADE(lu,surrogate,100,100,n); 
end

%%以下是自己加的
function y = ackley(x)%没问题
D=length(x);
xx=x.^2;
s1=sum(xx,2);
xxx=cos(2*pi*x);
s2=sum(xxx,2);      
y=(20-20*exp(-0.2*sqrt(1/D*s1)))+(exp(1)-exp(1/D*s2));
end 

function y=ellipsoid(x)%没问题
[n, d] = size(x); % n 是行数，d 是维度
A=1:d;
y=zeros(n,1);
    for i = 1:n
        y(i,1)=sum(A.*x(i,:).*x(i,:));
    end
end

function y = rosenbrock(X) %没问题
    [n, d] = size(X); % n 是行数，d 是维度
    
    % 初始化 z 为零向量
    y = zeros(n, 1);
    % 对于每一维度进行迭代计算
        for i = 1:(d-1)
            y = y + 100 * (X(:, i+1) - X(:, i).^2).^2 + (1 - X(:, i)).^2;
        end
end

function y=griewank(x)%没问题
  [n, d] = size(x);
    
    sum_term = sum(x.^2, 2) / 4000;
    prod_term = prod(cos(x ./ sqrt((1:d))), 2);
    
    y = 1 + sum_term - prod_term;
end

function y = rastrigin(X)%没问题
    A = 10;
    [n, d] = size(X); % n是行数，d是维度
    
    sum_term = sum(X.^2 - A * cos(2 * pi * X), 2);
    
    y = A * d + sum_term;
end