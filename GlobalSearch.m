function newpoint=GlobalSearch(Xmin,Xmax,datax,surrogate,samplesize,alpha,n)
         samples=repmat(Xmin,samplesize,1)+(repmat(Xmax,samplesize,1)-repmat(Xmin,samplesize,1)).*rand(samplesize,n);
         dist=pdist2(samples,datax);        
         mindist=min(dist,[],2);  
         deltag=alpha*max(mindist);
         index=find(mindist<=deltag);
         if ~isempty(index)
             samples(index,:)=[];
         end                
         fit = srgtsRBFEvaluate(samples, surrogate);
         [~,infill_id]=min(fit);
         newpoint=samples(infill_id,:);
end