function [datax,datay,FES,no_points,besty]=add_newpoint(infill,datax,datay,FES,no_points,besty,problem)
% dd1=pdist2(datax,infill);
% r1=min(dd1)>delta;
% if ~isempty(DX)
%     dd2=pdist2(DX,infill);
%     com=dd2>AR;
%     r2=(sum(com)==length(AR));
% else
%     r2=1;
% end
% accept=r1 && r2
% accept=r1;

% if accept
%     fit_infill=ldp_func(infill,problem);
%     if fit_infill<besty
%         besty=fit_infill;
%         cfail=0;
%     else
%         cfail=cfail+1;
%     end
%     datay=[datay; fit_infill];
%     datax=[datax;infill];
%     FES=FES+1;
%     no_points=no_points+1;
% end
fit_infill=ldp_func(infill,problem);
if fit_infill<besty
    besty=fit_infill;  
end
datay=[datay; fit_infill];
datax=[datax;infill];
FES=FES+1;
no_points=no_points+1;
end
