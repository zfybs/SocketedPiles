function [uy ry,moment]=uyzone(OriginalParameters,results,z)
% 求出在屈服段中指定深度位置处的水平位移与相应的转角。
% 输入参数
% OriginalParameters % 工程项目的原始计算参数
% results        最后一次有限差分法计算的结果
% z     UYZONE 函数会返回向量z中指定深度处的水平位移值。
%       z的取值是在0到Zy之间,z=0表示桩顶，z=Zy表示屈服截面处。
%       当自变量z为行向量时，输出的为行向量，当z为列向量时，输出为矩阵
%       所以最好先将z转为行向量。
%       与pult函数不同，由于uy,ry是以z为自变量的符号函数，可以直接输入自变量而求得结果，所以这里的自变量可以设为任意符号，而不一定要是z。
%
% 输出参数
% uy,ry,moment   屈服段中的位移、转角与弯矩的分布向量。为数值向量，而不是符号向量；
%               屈服段的顶部的位移、转角与弯矩分别是上面三个向量中的第一个元素。
%

%% 先计算屈服区中的位移的符号表达式
[uy_sym ry_sym moment_sym l_uyd]=getuyfun(OriginalParameters,results);
% 再根据给定的深度计算对应的位移向量
[uy ry,moment]=GetReaction_YieldZone(z,uy_sym, ry_sym,moment_sym,l_uyd);
%
% H_FDM=results.ShearForce{1}(1)  % 有限差分法计算得到的非屈服区顶部的弯矩
% M_FDM=results.BendingMoment{1}(1)  % 有限差分法计算得到的非屈服区顶部的弯矩
% bm1=moment(end)

%{
%% 测试弯矩的连接性
figure;hold on
subplot(2,1,2)
plot(moment,z,'*-')
set(gca,'ydir','reverse')
xlabel('弯矩')
ylabel('深度')
%
subplot(2,2,1)
plot(uy,z,'*-')
set(gca,'ydir','reverse')
xlabel('位移')
ylabel('深度')
%
subplot(2,2,2)
plot(ry,z,'*-')
set(gca,'ydir','reverse')
xlabel('转角')
ylabel('深度')
%}
end

% 得到用pultfun得到的符号函数uy、ry
function [uy_sym ry_sym moment l_uyd]=getuyfun(OriginalParameters,results)
% 对于嵌固端中的屈服段，进行位移计算
% 先用解析的办法求得位移和转角的表达式，再由边界条件得到未知数c和d
% 再对任意的z求解出对应的位移和转角
% z的取值是在0到Zy之间,z=0表示桩顶，z=Zy表示屈服截面处。
%
% 输入参数
% OriginalParameters % 工程项目的原始计算参数
% results        最后一次有限差分法计算的结果
%
% 输出参数
% uy_sym,ry_sym,moment
%           元胞数组，其中的每一个元素都是一个符号函数symfun，此函数用来表达指定深度处的位移、转角与弯矩。
%           每一层土中的符号自变量的范围都要限制在此层土所占据的相对于海床底部的绝对深度，而不是相对于此层顶部的深度。
% l_uyd     屈服区中每一层的长度
% see also  OriginalProjectParameters,FDMResults

%% 参数赋值
epip=OriginalParameters.epip;
% ip=OriginalParameters.ip;
nlayer=OriginalParameters.nlayer;
M=OriginalParameters.M;
H=OriginalParameters.H;
lstay=OriginalParameters.l;
pultfun=OriginalParameters.pultfun; % 一个符号函数，可以用来获取水下整个土层中任意深度处的极限承载力。
% 最终的未屈服段顶部节点的位移与转角
di=results.top_u;
ro=results.top_r;
Zy=results.physicalConditions.Zy;  % 屈服区顶端相对于整个土层的顶端的深度。
%
%%  计算屈服区中每一层的长度
for nYieldPart=1:nlayer  % nYieldPart 表示屈服截面位于地基的绝对层数。
    if Zy<sum(lstay(1:nYieldPart))
        break
    end
end
l_uyd(1:nYieldPart)=lstay(1:nYieldPart); % 未屈服区的每层的厚度。
l_uyd(nYieldPart)=lstay(nYieldPart)+Zy-sum(l_uyd);
%% 先“由上往下”得到弯矩表达式
moment=cell(1,nYieldPart);
z0=0;  % 代表嵌固端顶部的深度
z=sym('z');
pult_z=sym('pult_z');
for i=1:nYieldPart  % 从上往下计算弯矩
    % 下面的z是相对于整个嵌入段的顶部（即海床底部）的深度
    % 注意积分的自变量是pult_z，这里的符号变量只相当于常数。
    moment{i}(z)=M+H*(z-z0)-int(pultfun{i}(pult_z)*(z-pult_z),pult_z,z0,z); % 每一层的弯矩随z的函数。
    M=moment{i}(z0+l_uyd(i));  % 第i层底部的弯矩，即第i+1层顶部的弯矩
    H=H-int(pultfun{i}(pult_z),pult_z,z0,z0+l_uyd(i));% 第i层底部的水平力，即第i+1层顶部的水平力
    z0=z0+l_uyd(i);
end
%% 再“从下至上”由已得到的弯矩函数求得位移函数。
uy_sym=cell(1,nYieldPart);
ry_sym=cell(1,nYieldPart);
for i_inverse=1:nYieldPart
    syms c d
    j=nYieldPart+1-i_inverse; % j为倒数第i_inverse层
    uy_sym{j}=(int(int(moment{j},z),z)+c*z+d)/epip(j);  % 第j层任意深度处的位移表达式：由弯矩M=EIy"
    ry_sym{j}=diff(uy_sym{j},z);                          % 第j层任意深度处的转角表达式：由转角r=dy/dz
    f1=uy_sym{j}(sum(l_uyd(1:j)))-di; %位移连续：此层底部的位移等于其下面一层顶部的位移
    f2=ry_sym{j}(sum(l_uyd(1:j)))-ro; %转角连续：此层底部的转角等于其下面一层顶部的转角
    % 由边界条件消除变量c、d
    [c d]=solve(f1,f2,c,d);
    c=subs(c);
    d=subs(d);
    %% 得到所有求的分段位移函数uy{j}(z)与分段转角函数ry{j}(z)，以及嵌固端顶的位移di与转角ro
    uy_sym{j}=subs(uy_sym{j});  % 将uy函数中的符号变量c、d替换为对应的值，但uy函数中只存在变量z。
    ry_sym{j}=subs(ry_sym{j});
    toprelative=sum(l_uyd(1:j))-sum(l_uyd(j));
    di=uy_sym{j}(toprelative); % 此层顶部的位移值，同时作为求其上面一层的位移时的位移边界。
    ro=ry_sym{j}(toprelative); % 此层顶部的转角值，同时作为求其上面一层的位移时的转角边界。
end
% 最后的di,ro即代表整个屈服区顶部（即海床底部）的位移与转角
end


function [uy,ry,moment]=GetReaction_YieldZone(z,uy_sym, ry_sym,moment_sym,l_uyd)
% 求出在屈服段中指定深度位置处的水平位移与相应的转角。
% 输入参数
% z     UYZONE 函数会返回向量z中指定深度处的水平位移值。
%       z的取值是在0到Zy之间,z=0表示桩顶，z=Zy表示屈服截面处。
%       当自变量z为行向量时，输出的为行向量，当z为列向量时，输出为矩阵
%       所以最好先将z转为行向量。
%       与pult函数不同，由于uy,ry是以z为自变量的符号函数，可以直接输入自变量而求得结果，所以这里的自变量可以设为任意符号，而不一定要是z。
% uy_sym,ry_sym,moment
%           元胞数组，其中的每一个元素都是一个符号函数symfun，此函数用来表达指定深度处的位移、转角与弯矩。
%           每一层土中的符号自变量的范围都要限制在此层土所占据的相对于海床底部的绝对深度，而不是相对于此层顶部的深度。
% l_uyd       嵌固端中屈服段占据整个土层从上至下的的前nypart层，每层的厚度由l_uyd来定义,也即有sum(l_uyd)=Zy.
%
% 输出参数
% uy,ry,moment   屈服段中的位移、转角与弯矩的分布向量。为数值向量，而不是符号向量；
%               屈服段的顶部的位移、转角与弯矩分别是上面三个向量中的第一个元素。
%
%% 确宝z为行向量。
if size(z,2)==1
    z=z';
end
%%
nypart=length(l_uyd); % 嵌固端中屈服段占据整个土层从上至下的前nypart层
suml=0;
uy=0;
ry=0;
moment=0;
for i=1:nypart
    logic=(z>=suml & z<sum(l_uyd(1:i)));
    zlogic=logic.*z;
    %
    uy_part=uy_sym{i}(zlogic).*logic; % 为了满足下面直接覆盖的关系，在这里一定要点乘一个logic。
    uy=uy_part+uy;
    %
    ry_part=ry_sym{i}(zlogic).*logic;
    ry=ry_part+ry;
    %
    moment_part=moment_sym{i}(zlogic).*logic;
    moment=moment_part+moment;
    %
    suml=sum(l_uyd(1:i));
end
if max(z)>sum(l_uyd)-eps(max(z))  % 考虑到最末尾的点不在上面的逻辑范围之内。
    
    ind=find(z>sum(l_uyd)-eps(max(z)));
    uy(ind)=uy_sym{nypart}(sum(l_uyd));
    ry(ind)=ry_sym{nypart}(sum(l_uyd));
    moment(ind)=moment_sym{nypart}(sum(l_uyd));
end
%% 将输出结果由符号变量转换为double型。当然也可以不转换。
uy=double(uy);
ry=double(ry);
moment=double(moment);
end
