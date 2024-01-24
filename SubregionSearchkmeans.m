function newpoint=SubregionSearchkmeans(datax,datay,L1, L2,Basisfunction,c,n,no_points)
if no_points<=L1
    options= srgtsRBFSetOptions(datax, datay,@rbf_build,0,Basisfunction,c,0);
    [surrogate, ~] = srgtsRBFFit(options);   
    tempdatax=datax;
else
    Csize=1+ceil((no_points-L1)/L2);
    normalized_datax=mapminmax(datax',0,1)';
    %[~,u,~]=myfcm(normalized_datax,Csize); 
    %u=u';
    [cluster_idx,cluster_centers] = kmeans(normalized_datax,Csize);
    u = find(cluster_idx);
    [~,sortid]=sort(u,'descend');
    C=[];
    mper=[];
    hold on
    for k=1:Csize
        C{k}=datax(sortid(1:L1,k),:);
        Y{k}=datay(sortid(1:L1,k),1);
        mper(k)=mean(Y{k});
        options= srgtsRBFSetOptions(C{k}, Y{k},@rbf_build,0,Basisfunction,c,0);
        [Surrogate{k}, State{k}] = srgtsRBFFit(options);
        surrogate=Surrogate{k};
    end
    [~,sortid]=sort(mper,'descend');
    pro=sortid/Csize;
    sid=randi([1,Csize],1);
    while rand>pro(sid)
        sid=randi([1,Csize],1);
    end   
    tempdatax=C{sid};
    surrogate=Surrogate{sid};     
end
      lu=[min(tempdatax);max(tempdatax)];  
      newpoint=JADE(lu,surrogate,100,100,n); 
end