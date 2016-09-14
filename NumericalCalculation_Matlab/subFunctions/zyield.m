function zAdd=zyield(OriginalParameters,fdm_result)
% 注意zstart的相关深度和pult(z)的绝对深度的区别与转换
% 由前面的Zy求得下一个zyrelative，并将它赋值给下一个zy(num+1)
% 此函数用来找出相对屈服深度zstart，再依此进行后续的对桩进行分段的计算;
% 输入参数
% fdm_result    最新的有限差分法的计算结果；
%
% 输出参数：
% zAdd    相对于上一个屈服点的新的屈服深度，zAdd=0 表示没有屈服；
% see also:FDMResults,OriginalProjectParameters
global SearchingDirection
% 根据不同的具体情况选用不同的搜索方式
if SearchingDirection   % addUpwards 从下往上搜索
    zAdd=SearchingUpwards(OriginalParameters,fdm_result);
else   % addDownwards 从上往下搜索
    zAdd=SearchingDownwards(OriginalParameters,fdm_result);
end
% if abs(addDownwards-addUpwards)>0.001
%     fprintf(2,['提示：出现不一样的解，即有上下至少两个屈服点。\n','二者之差为：' ...
%         num2str(addDownwards-addUpwards), 'm\n'])
% end


end

% 处理方式一：从下往上找屈服点
function zAdd=SearchingUpwards(OriginalParameters,fdm_result)
%% 参数设置
Zy=fdm_result.physicalConditions.Zy;% 上一个屈服点的深度，此深度值是相对于土层顶的；
l=fdm_result.physicalConditions.l;% 一个向量，代表原来的未屈服区的每一层土的长度；
%% 用二分法逼近zy的解。
% 处理方式一：从下往上找屈服点
n=200;  % 二分法分段的精度，即每一半分为多少段。
% 当n过小时，可能会由于曲线变化过快而漏掉现曲线的交点。但好在pult与pz的曲线变化都不快。
zEnd=sum(l); % 如果没有屈服，则zstart只能为0，所以这里并不是随意赋值。
lpart=sum(l);
toler=1;
while toler>0.0001   % 每一个小分段的长度
    half=lpart/2;
    z=linspace(zEnd,zEnd-half,n+1)'; % 将进行比较的总长划分为n份
    zpult=z+Zy;
    % 考虑到反力的方向可能向左（pz值为正），也可能向右（pz值为负），而pult的值始终为正，所以应该用pult与pz的绝对值进行比较。
    compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %得到的compare是一个列向量
    f=find(compare<=0,1);
    if ~isempty(f)   %在下半段有解
        if f>1
            zEnd=z(f-1);
        end
        toler=(half)/n;  % 这一次计算（而不是下一次计算）的分段长度。
        lpart=toler;  % 此时可以将零点锁定在zEnd到其上面一个小节点之间。这一小段的长度为(half)/n
    else            %下半段无解，解有可能在上半段，也有可能上半段也无解。
        z=linspace(zEnd-half,zEnd-lpart,n+1)';
        zpult=z+Zy;
        compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %得到的compare是一个列向量
        g=find(compare<=0,1);
        if ~isempty(g)   %在上半段有解
            if g>1
                zEnd=z(g-1);% 这里必须要取zstart=z(g)，而不能取zstart=z(g-1)，这是因为linspace函数会将其最后的一个值根据分段间距n进行一定的舍入操作。
            end
            toler=(half)/n;  % 这一次计算（而不是下一次计算）的分段长度。
            lpart=toler;  % 此时可以将零点锁定在zEnd到其上面一个小节点之间。这一小段的长度为(half)/n
        else            %下半段也无解,即全段都没有屈服
            zEnd=0;
            break
        end
    end
end
zAdd=zEnd;
end

% 处理方式二：从上往下找屈服点
function zAdd=SearchingDownwards(OriginalParameters,fdm_result)
%% 参数设置
Zy=fdm_result.physicalConditions.Zy;% 上一个屈服点的深度，此深度值是相对于土层顶的；
l=fdm_result.physicalConditions.l;% 一个向量，代表原来的未屈服区的每一层土的长度；
%% 用二分法逼近zy的解。
% 处理方式二：从上往下找屈服点
n=200;  % 二分法分段的精度，即每一半分为多少段。
% 当n过小时，可能会由于曲线变化过快而漏掉现曲线的交点。但好在pult与pz的曲线变化都不快。
zstart=0; % 如果没有屈服，则zstart只能为0，所以这里并不是随意赋值。
lpart=sum(l);
toler=1;
while toler>0.0001
    half=lpart/2;
    z=linspace(zstart,zstart+half,n+1)'; % z should be a coloum vector.
    zpult=z+Zy;
    % 考虑到反力的方向可能向左（pz值为正），也可能向右（pz值为负），而pult的值始终为正，所以应该用pult与pz的绝对值进行比较。
    compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %得到的compare是一个列向量
    f=find(compare>0,1);
    if ~isempty(f)   %在上半段有解
        if f>1
            zstart=z(f-1);
        end
        toler=(half)/n;  % 这一次计算（而不是下一次计算）的分段长度。
        lpart=toler;  % 此时可以将零点锁定在zEnd到其上面一个小节点之间。这一小段的长度为(half)/n
    else            %上半段无解，解有可能在下半段，也有可能下半段也无解。
        z=linspace(zstart+half,zstart+lpart,n+1)';
        zpult=z+Zy;
        compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %得到的compare是一个列向量
        g=find(compare>0,1);
        if ~isempty(g)   %在下半段有解
            if g>1
                zstart=z(g-1);
            end
            toler=(half)/n;  % 这一次计算（而不是下一次计算）的分段长度。
            lpart=toler;  % 此时可以将零点锁定在zEnd到其上面一个小节点之间。这一小段的长度为(half)/n
        else            %下半段也无解,即全段都没有屈服
            break
        end
    end
end
zAdd=zstart;
end
