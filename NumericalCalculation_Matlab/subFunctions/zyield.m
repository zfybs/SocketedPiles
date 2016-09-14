function zAdd=zyield(OriginalParameters,fdm_result)
% ע��zstart�������Ⱥ�pult(z)�ľ�����ȵ�������ת��
% ��ǰ���Zy�����һ��zyrelative����������ֵ����һ��zy(num+1)
% �˺��������ҳ�����������zstart�������˽��к����Ķ�׮���зֶεļ���;
% �������
% fdm_result    ���µ����޲�ַ��ļ�������
%
% ���������
% zAdd    �������һ����������µ�������ȣ�zAdd=0 ��ʾû��������
% see also:FDMResults,OriginalProjectParameters
global SearchingDirection
% ���ݲ�ͬ�ľ������ѡ�ò�ͬ��������ʽ
if SearchingDirection   % addUpwards ������������
    zAdd=SearchingUpwards(OriginalParameters,fdm_result);
else   % addDownwards ������������
    zAdd=SearchingDownwards(OriginalParameters,fdm_result);
end
% if abs(addDownwards-addUpwards)>0.001
%     fprintf(2,['��ʾ�����ֲ�һ���Ľ⣬���������������������㡣\n','����֮��Ϊ��' ...
%         num2str(addDownwards-addUpwards), 'm\n'])
% end


end

% ����ʽһ������������������
function zAdd=SearchingUpwards(OriginalParameters,fdm_result)
%% ��������
Zy=fdm_result.physicalConditions.Zy;% ��һ�����������ȣ������ֵ����������㶥�ģ�
l=fdm_result.physicalConditions.l;% һ������������ԭ����δ��������ÿһ�����ĳ��ȣ�
%% �ö��ַ��ƽ�zy�Ľ⡣
% ����ʽһ������������������
n=200;  % ���ַ��ֶεľ��ȣ���ÿһ���Ϊ���ٶΡ�
% ��n��Сʱ�����ܻ��������߱仯�����©�������ߵĽ��㡣������pult��pz�����߱仯�����졣
zEnd=sum(l); % ���û����������zstartֻ��Ϊ0���������ﲢ�������⸳ֵ��
lpart=sum(l);
toler=1;
while toler>0.0001   % ÿһ��С�ֶεĳ���
    half=lpart/2;
    z=linspace(zEnd,zEnd-half,n+1)'; % �����бȽϵ��ܳ�����Ϊn��
    zpult=z+Zy;
    % ���ǵ������ķ����������pzֵΪ������Ҳ�������ң�pzֵΪ��������pult��ֵʼ��Ϊ��������Ӧ����pult��pz�ľ���ֵ���бȽϡ�
    compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %�õ���compare��һ��������
    f=find(compare<=0,1);
    if ~isempty(f)   %���°���н�
        if f>1
            zEnd=z(f-1);
        end
        toler=(half)/n;  % ��һ�μ��㣨��������һ�μ��㣩�ķֶγ��ȡ�
        lpart=toler;  % ��ʱ���Խ����������zEnd��������һ��С�ڵ�֮�䡣��һС�εĳ���Ϊ(half)/n
    else            %�°���޽⣬���п������ϰ�Σ�Ҳ�п����ϰ��Ҳ�޽⡣
        z=linspace(zEnd-half,zEnd-lpart,n+1)';
        zpult=z+Zy;
        compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %�õ���compare��һ��������
        g=find(compare<=0,1);
        if ~isempty(g)   %���ϰ���н�
            if g>1
                zEnd=z(g-1);% �������Ҫȡzstart=z(g)��������ȡzstart=z(g-1)��������Ϊlinspace�����Ὣ������һ��ֵ���ݷֶμ��n����һ�������������
            end
            toler=(half)/n;  % ��һ�μ��㣨��������һ�μ��㣩�ķֶγ��ȡ�
            lpart=toler;  % ��ʱ���Խ����������zEnd��������һ��С�ڵ�֮�䡣��һС�εĳ���Ϊ(half)/n
        else            %�°��Ҳ�޽�,��ȫ�ζ�û������
            zEnd=0;
            break
        end
    end
end
zAdd=zEnd;
end

% ����ʽ��������������������
function zAdd=SearchingDownwards(OriginalParameters,fdm_result)
%% ��������
Zy=fdm_result.physicalConditions.Zy;% ��һ�����������ȣ������ֵ����������㶥�ģ�
l=fdm_result.physicalConditions.l;% һ������������ԭ����δ��������ÿһ�����ĳ��ȣ�
%% �ö��ַ��ƽ�zy�Ľ⡣
% ����ʽ��������������������
n=200;  % ���ַ��ֶεľ��ȣ���ÿһ���Ϊ���ٶΡ�
% ��n��Сʱ�����ܻ��������߱仯�����©�������ߵĽ��㡣������pult��pz�����߱仯�����졣
zstart=0; % ���û����������zstartֻ��Ϊ0���������ﲢ�������⸳ֵ��
lpart=sum(l);
toler=1;
while toler>0.0001
    half=lpart/2;
    z=linspace(zstart,zstart+half,n+1)'; % z should be a coloum vector.
    zpult=z+Zy;
    % ���ǵ������ķ����������pzֵΪ������Ҳ�������ң�pzֵΪ��������pult��ֵʼ��Ϊ��������Ӧ����pult��pz�ľ���ֵ���бȽϡ�
    compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %�õ���compare��һ��������
    f=find(compare>0,1);
    if ~isempty(f)   %���ϰ���н�
        if f>1
            zstart=z(f-1);
        end
        toler=(half)/n;  % ��һ�μ��㣨��������һ�μ��㣩�ķֶγ��ȡ�
        lpart=toler;  % ��ʱ���Խ����������zEnd��������һ��С�ڵ�֮�䡣��һС�εĳ���Ϊ(half)/n
    else            %�ϰ���޽⣬���п������°�Σ�Ҳ�п����°��Ҳ�޽⡣
        z=linspace(zstart+half,zstart+lpart,n+1)';
        zpult=z+Zy;
        compare=OriginalParameters.GetPult(zpult)-abs(fdm_result.GetPz(z));  %�õ���compare��һ��������
        g=find(compare>0,1);
        if ~isempty(g)   %���°���н�
            if g>1
                zstart=z(g-1);
            end
            toler=(half)/n;  % ��һ�μ��㣨��������һ�μ��㣩�ķֶγ��ȡ�
            lpart=toler;  % ��ʱ���Խ����������zEnd��������һ��С�ڵ�֮�䡣��һС�εĳ���Ϊ(half)/n
        else            %�°��Ҳ�޽�,��ȫ�ζ�û������
            break
        end
    end
end
zAdd=zstart;
end
