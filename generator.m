function o=generator(datax,datay,no_points,i,Xmin,Xmax,n)

[~,bestid]=min(datay);
% generate the first trial vector
indexSet = 1 : no_points;
indexSet(i)=[];
% Choose the first Index
temp = floor(rand * (no_points-1)) + 1;
r1 = indexSet(temp);
indexSet(temp) = [];
% Choose the second index
temp = floor(rand * (no_points - 2)) + 1;
r2 = indexSet(temp);
indexSet(temp) = [];
% Choose the third index
temp = floor(rand * (no_points - 3)) + 1;
r3 = indexSet(temp);
v=datax(bestid,:)+rand*(datax(r1,:)-datax(r2,:));
%handle constraint
index1=find(v<Xmin); index2=find(v>Xmax);
if ~isempty(index1)
    v(index1)=Xmin(index1)+(Xmax(index1)-Xmin(index1)).*rand(1,length(index1));
end
if ~isempty(index2)
    v(index2)=Xmin(index2)+(Xmax(index2)-Xmin(index2)).*rand(1,length(index2));
end
j_rand = floor(rand * n) + 1;
t = rand(1, n) < rand;
t(1, j_rand) = 1;
t_ = 1 - t;
o(1,:)=t .* v + t_ .*datax(i, :);

% generate the second trial vector
indexSet = 1 : no_points;
indexSet(i)=[];
% Choose the first Index
temp = floor(rand * (no_points-1)) + 1;
r1 = indexSet(temp);
indexSet(temp) = [];
% Choose the second index
temp = floor(rand * (no_points - 2)) + 1;
r2 = indexSet(temp);
indexSet(temp) = [];
% Choose the third index
temp = floor(rand * (no_points - 3)) + 1;
r3 = indexSet(temp);

v=datax(i,:)+rand*(datax(bestid,:)-datax(i,:))+rand*(datax(r2,:)-datax(r3,:));
%handle constraint
index1=find(v<Xmin); index2=find(v>Xmax);
if ~isempty(index1)
    v(index1)=Xmin(index1)+(Xmax(index1)-Xmin(index1)).*rand(1,length(index1));
end
if ~isempty(index2)
    v(index2)=Xmin(index2)+(Xmax(index2)-Xmin(index2)).*rand(1,length(index2));
end
o(2,:)= v ;
end