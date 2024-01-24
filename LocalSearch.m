function newpoint=LocalSearch(datax,datay,Basisfunction,c,n,k)
    [~,bestid]=min(datay);
    dist=pdist2(datax,datax(bestid,:));
    [~,sortid]=sort(dist,'ascend');   
    sid=sortid(1:k);   
    local_datax=datax(sid,:);
    local_datay=datay(sid,1);
    lu=[min(local_datax);max(local_datax)];

    %RBF
    %options= srgtsRBFSetOptions(local_datax, local_datay,@rbf_build,0,Basisfunction,c,0);
    %[surrogate, ~] = srgtsRBFFit(options);

    %KRG
    options= srgtsKRGSetOptions(local_datax, local_datay);
    [surrogate, ~] = srgtsKRGFit(options);

    newpoint=JADE(lu,surrogate,100,100,n);
end