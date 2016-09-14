function [H M e1 e2 v epip l nlayer,zy]=parachange(OriginalParameters,physicalConditions,pultfun,zy,zynum)
%由于考虑屈服，在得出屈服区间zy后，要对相关参数进行修改，继而对桩进行截断。
%所有的参数改变都是相对于上一次截断后的桩而言的。
% 
% 注意：如果减去新的屈服段长度后，所得到的新的非屈服区中，每一层土的长度过短（比如小于1cm），
%       就应该将这个最顶层处理为全部屈服。这是为了避免在进行有限差分法时，h(1)的值过小而导致Ax=b中的非奇次向量b接近于零向量。
%
% 输入参数
% pultfun   整个土层的极限承载力表达式，此属性为一个元胞数组，数组中以符号变量保存每一层土中任意深度处的极限承载力的表达式。
%           在确定新的屈服点后，进行物理参数的修改时，可利用此符号变量来进行积分运算
%           其中内含的自变量的符号为“pult_z”。
% zynum     表示整根桩已经发生屈服的次数。所以第一次执行此函数时，zynum的值为1。
%
% 输出参数
% zy        修正后的zy值。如果新的屈服点位于某一层未屈服区的土层中的底部以上1cm以内的范围中，
%           那么要将这个屈服点的位置修正为下一层土的顶部。所以此时向量zy中zy(zynum)的值也要进行修正——加上修正的那一段小于1cm的长度。
% nlayer    参数修正后，新的未屈服区的土层数，以及因为nlayer改变而使向量参数e1,e2,v,ep发生的改变。
% H         参数修正后，新的未屈服区的顶部的水平荷载；
% M         参数修正后，新的未屈服区的顶部的弯矩；
% ep        参数修正后，新的未屈服区的每一层桩的弹性模量。桩的弹性模量值本来应该在整个嵌固段都是一样的，
%           但是，如果要考虑桩中的弯矩越大时，由于桩的屈服引起桩的抗弯刚度减小，则此时要对桩中的弹性模量进行修正。
% see also:finitedifference

%% 参数设置
H=physicalConditions.H;
M=physicalConditions.M;
e1=physicalConditions.e1;
e2=physicalConditions.e2;
v=physicalConditions.v;
epip=physicalConditions.epip;
nlayer=physicalConditions.nlayer;
l=physicalConditions.l;
original_l=OriginalParameters.l; % 绝对桩长lstay，用于pult函数的自变量的参考。
original_nlayer=OriginalParameters.nlayer;
%
newzy=zy(zynum);    % 最新的屈服点相对于其上一个屈服点的长度
Zy=sum(zy);         % Zy 表示参数修正前，FDM计算所得的屈服点位于的绝对深度。
%%
z=sym('z');
tolerance=0.01; % 如果减去新的屈服段长度后，所得到的新的非屈服区中，每一层土的长度过短（比如小于1cm），
%       就应该将这个最顶层处理为全部屈服。这是为了避免在进行有限差分法时，h(1)的值过小而导致Ax=b中的非奇次向量b接近于零向量。
%% 首先确定三个重要参数n1,n2,n3
% n1 表示参数修正前，FDM计算所得的屈服点所位于的相对于已知的未屈服段的层数。
%    比如未屈服段一共有三层，而最新计算出现的屈服点位于其中的第二层，则n1=2。
%    同时n1也代表了新增加的屈服区所占的土层的数量。
% n2 表示参数修正前，FDM计算所得的屈服点所位于的绝对层数。
% n3 表示参数修正前，未屈服段顶端截面所位于的绝对层数。
% 有关系式：n1-n2+n3=1 !
for n1=1:nlayer     % n1是FDM计算并比较所得的新屈服点所位于的相对于已知的未屈服段的层数。比如未屈服段一共有三层，而最新计算出现的屈服点位于其中的第二层，则n1=2。
    a=sum(l(1:n1));
    if newzy<a-tolerance % 这是一步很重要的设置，这是为了保证参数修正后的未屈服段顶部所在的未屈服土层的长度大于1cm。
        break
    else
        if newzy<a  % 说明屈服点位于这一层顶部以上1cm的范围之内。
            % 此时要做两步操作：
            zy(zynum)=sum(l(1:n1));% 1、将zy向量中的zy(zynum)的值加上修正的那个小于1cm的长度。
            n1=n1+1; % 2、将屈服点所在的层数处理为其实际所在土层的下一层中。
            break
        end
    end
end
%
nk=zeros(1,original_nlayer);
j=1;
for n2=1:original_nlayer      % n2 表示参数修正前，FDM计算所得的屈服点所位于的绝对层数。
    b=sum(original_l(1:n2));
    if Zy-newzy<b       % Zy-newzy 表示参数修正前，未屈服区顶端所位于的绝对深度。
        nk(j)=n2;
        j=j+1;
        if Zy<b-tolerance         % Zy 表示参数修正前，FDM计算所得的屈服点位于的绝对深度。
            break
        end
    end
end
n3=nk(1);               % n3 表示参数修正前，未屈服段顶端截面所位于的绝对层数。
%% 参数修改
nlayer=nlayer-n1+1;  % 确定新的桩段还能分为nlayer层。
% 注意下面参数修改的顺序
M=double(M+H*newzy-intM(pultfun,n1,n2,n3,z,Zy,newzy,l,original_l));  % 先改变M，而不能先改变H，因为M中需要未改变前的H。
H=double(H-intH(pultfun,n1,n2,n3,z,Zy,newzy,l,original_l));

%%
if n1==1
    k=e1(1)/e2(1);
    e1(1)=e2(1)*(k+(1-k)*newzy/l(1));
    l(1)=l(1)-newzy;
else
    % 修改在一层中均匀分布的参数
    v(1:n1-1)=[];
    epip(1:n1-1)=[];
    e1(1:n1-1)=[];
    e2(1:n1-1)=[];

    l(1:n1-1)=[];
    
    k=e1(1)/e2(1);
    relativelength=Zy-sum(original_l(1:n2-1));
    e1(1)=e2(1)*(k+(1-k)*relativelength/l(1));
    
    l(1)=sum(original_l(1:n2))-Zy;
end
end
%% 子函数intM，对pult*(zy-z)在0到zy上积分来求弯矩M
% 探讨如何对于自定义函数，用数组来作为参数？而不用循环的方式。

function pultM=intM(pultfun,n1,n2,n3,z,Zy,newzy,l,original_l)
% 对于以绝对值定义的积分限，M的积分中，(zy-z)要注意其与绝对深度的关系。
% intM与intH的区别就在于，在积分函数中，将pultfun{n2}(z)修改成了pultfun{n2}(z)*(Zy-z)。
% n1 表示参数修正前，FDM计算所得的屈服点所位于的相对于已知的未屈服段的层数。
%    比如未屈服段一共有三层，而最新计算出现的屈服点位于其中的第二层，则n1=2。
%    同时n1也代表了新增加的屈服区所占的土层的数量。
% n2 表示参数修正前，FDM计算所得的屈服点所位于的绝对层数。
% n3 表示参数修正前，未屈服段顶端截面所位于的绝对层数。
% 有关系式：n1+n3-1 = n2 !
if n1==1        % 说明新的屈服点没有跨越土层
    pultM=int(pultfun{n2}(z)*(Zy-z),z,Zy-newzy,Zy);
else
    pultM_part=zeros(1,n1-1);
    int_start=Zy-newzy;% Zy-newzy 表示参数修正前，未屈服区顶端所位于的绝对深度。
    for i=1:n1-1
        pultM_part(i)=int(pultfun{n3+i-1}(z)*(Zy-z),z,int_start,int_start+l(i));
        % pultM_part(i)指每一层的极限承载力对newzy截面产生和弯矩。
        int_start=int_start+l(i);
    end
    pultM_end=int(pultfun{n2}(z)*(Zy-z),z,sum(original_l(1:n2-1)),Zy);% 屈服点所在土层
    pultM=sum(pultM_part)+pultM_end;
end
end

%% 子函数intH，对pult在0到zy上积分来求水平荷载H
function pultH=intH(pultfun,n1,n2,n3,z,Zy,newzy,l,original_l)
% 注意：pultfun 函数的参数应该是绝对深度，必须要进行转换！！！
% 积分限只能以绝对值来定义。
% n1 表示参数修正前，FDM计算所得的屈服点所位于的相对于已知的未屈服段的层数。
%    比如未屈服段一共有三层，而最新计算出现的屈服点位于其中的第二层，则n1=2。
%    同时n1也代表了新增加的屈服区所占的土层的数量。
% n2 表示参数修正前，FDM计算所得的屈服点所位于的绝对层数。
% n3 表示参数修正前，未屈服段顶端截面所位于的绝对层数。
% 有关系式：n1+n3-1 = n2 !
if n1==1      % 说明新的屈服点没有跨越土层
    pultH=int(pultfun{n2}(z),z,Zy-newzy,Zy);
else
    pultH_part=zeros(1,n1-1);
    int_start=Zy-newzy;% Zy-newzy 表示参数修正前，未屈服区顶端所位于的绝对深度。
    for i=1:n1-1    % 屈服点所在土层的上部的所有未屈服土层。
        pultH_part(i)=int(pultfun{n3+i-1}(z),z,int_start,int_start+l(i));
        int_start=int_start+l(i);
    end
    pultH_end=int(pultfun{n2}(z),z,sum(original_l(1:n2-1)),Zy); % 屈服点所在土层
    pultH=sum(pultH_part)+pultH_end;
end
end


