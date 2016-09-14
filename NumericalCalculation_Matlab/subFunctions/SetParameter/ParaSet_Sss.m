function OriginalParameters = ParaSet_Sss(sss,SectionDefinitions)
% ParaSet_Sss, sss ��ָ SocketedShaftSystem
% ���������
%       SectionDefinitions �� ����ϵͳ�����е�׮���涨��

%
soilLayers = sss.SoilLayers.SoilLayerEntity ; %% ����ķֲ�
shaftSections = sss.SocketedShaft.Sections.ShaftSectionEntity; %% ׮�ķֶ�

% ��ȡ׮������ķֶ���Ϣ
[sectionBoundarys, sectionGuids] = GetSectionEntities(shaftSections);
[soilBoundarys, soilGuids] = GetSoilEntities(soilLayers);
soilTop = soilBoundarys(1,1);
shaftTop = sectionBoundarys(1,1);
shaftBottom =  sectionBoundarys(end,2);

% ˮ��׮�εĴ���
lw = shaftTop - soilTop;
if lw >=0
    waterSectionGuid =  sectionGuids{1};
    waterSectionDefinition = MatchSectionWithGuid(SectionDefinitions,waterSectionGuid);
    class_pileType_Water=PileType(waterSectionDefinition.Name,waterSectionDefinition.BendingMoment,waterSectionDefinition.BendingStiffness);
end

% ���������׮�ķֶν��н�һ����ϸ��

soilSeperators=[ soilBoundarys(:,1);soilBoundarys(end,2)];
sectionSeperators = [sectionBoundarys(:,1);sectionBoundarys(end,2)];
subdivision = SortAndDiscardDuplicate([soilSeperators;sectionSeperators]);
% ֻȡ������׮�������һ�����������޲�ּ���
soilSeperators = subdivision(subdivision<=soilTop & subdivision >= shaftBottom);
nlayer = length(soilSeperators)-1;  % ����ȷ������������

%% Ϊÿһ�����������С���㣨С׮�Σ���ȡ��Ӧ����������Լ�׮�������
% ͨ��ȷ����һС�ֶε��е�ı��λ����һ��׮���������С������
R        = sss.SocketedShaft.ATTRIBUTE.R;
class_pileType=cell(nlayer,1);
earthType= zeros(nlayer,1);
GSI      = zeros(nlayer,1);
J        = zeros(nlayer,1);
cu       = zeros(nlayer,1);
e1       = zeros(nlayer,1);
e2       = zeros(nlayer,1);
epip     = zeros(nlayer,1);
l        = zeros(nlayer,1);
mi       = zeros(nlayer,1);
phieff   = zeros(nlayer,1);
reff     = zeros(nlayer,1);
sigma_c  = zeros(nlayer,1);
v        = zeros(nlayer,1);

for i = 1 :nlayer
    middlePoint =( soilSeperators(i)+soilSeperators(i+1))/2;
    % ׮�ν��涨��
    sectionGuidIndex = IndexOf(sectionBoundarys, middlePoint);
    sectionDefinition = MatchSectionWithGuid(SectionDefinitions,sectionGuids{sectionGuidIndex});
    % �����������
    soilGuidIndex = IndexOf(soilBoundarys, middlePoint);
    soilDefinition = MatchSoilWithGuid(sss.SoilDefinitions,soilGuids{soilGuidIndex});
    
    % ����һС��ĸ��ֲ������и�ֵ
    earthType(i) =  convertSoilType( soilDefinition.Type);
    class_pileType{i} = PileType(sectionDefinition.Name,sectionDefinition.BendingMoment,sectionDefinition.BendingStiffness);
    GSI      (i) =   soilDefinition.GSI;
    J        (i) =   soilDefinition.J;
    cu       (i) =   soilDefinition.CU;
    e1       (i) =   soilDefinition.E1 * 1e6;  % �� MPa ת��Ϊ Pa
    e2       (i) =   soilDefinition.E2 * 1e6;  % �� MPa ת��Ϊ Pa
    epip     (i) =   sectionDefinition.BendingStiffness(1);
    l        (i) =   soilSeperators(i) - soilSeperators(i+1);
    mi       (i) =   soilDefinition.mi;
    phieff   (i) =   soilDefinition.EffectiveFrictionAngle;
    reff     (i) =   soilDefinition.EffectiveUnitWeight;
    sigma_c  (i) =   soilDefinition.CompressiveStrength;
    v        (i) =   soilDefinition.PoissonRatio;
end

% �����еĲ���д��һ������
OriginalParameters = OriginalProjectParameters(sss.SocketedShaft.ATTRIBUTE.Name ,earthType,GSI,J,R,cu,e1,e2,epip,l,lw, ...
    mi,nlayer,phieff,reff,sigma_c,v,class_pileType,class_pileType_Water);
end

%%
function sorted = SortAndDiscardDuplicate(Array)
% �������е���ֵ�Ӵ�С���У�����������е���ֵͬ
sorted=sort(Array,'descend');
b = sorted(1:end-1) == sorted(2:end);
sorted(b)=[];
end

%% ��һ�дӴ�С���е������У��ҵ�ĳһ�����ֵ���ڵ�λ��
function index = IndexOf(elevationArray, middleElev)
a = ( elevationArray(:,1)>middleElev) & elevationArray(:,2)<middleElev;
index = find(a);
end

%%
% ��ȡÿһ��׮�ε����±�ߣ��Լ���Ӧ�Ľ��涨�������
function [boundarys, ids] = GetSectionEntities(shaftSections)
n =  length(shaftSections);
boundarys = zeros(n,2);
ids = cell(n,1);
for i = 1 : n
    section = shaftSections(i);
    boundarys(i,1)=section.ATTRIBUTE.Top;
    boundarys(i,2)=section.ATTRIBUTE.Bottom;
    ids{i} = section.Section.ID;
end
end

% ��ȡÿһ������ε����±�ߣ��Լ���Ӧ��������������GUIDֵ
function [boundarys, ids] = GetSoilEntities(soilLayers)
n =  length(soilLayers);
boundarys = zeros(n,2);
ids = cell(n,1);
for i = 1 : n
    soilLayer = soilLayers(i);
    boundarys(i,1)=soilLayer.ATTRIBUTE.Top;
    boundarys(i,2)=soilLayer.ATTRIBUTE.Bottom;
    ids{i} = soilLayer.Layer.ID;
end
end

function sectionDefinition = MatchSectionWithGuid(sectionDefinitions,Guid)
for i  = 1 : length(sectionDefinitions)
    if  strcmp(sectionDefinitions(i).ID,Guid)
        sectionDefinition = sectionDefinitions(i);
        return;
    end
end
end

function soilDefinition = MatchSoilWithGuid(soilDefinitions,Guid)
for i  = 1 : length(soilDefinitions)
    if  strcmp(soilDefinitions(i).ID,Guid)
        soilDefinition = soilDefinitions(i).ATTRIBUTE;
        return;
    end
end
end

function num = convertSoilType(typeName)
switch typeName
    case 'Clay'
        num = 1;
    case 'Sand'
        num = 2;
    case 'RockSmooth'
        num = 3;
    case 'RockRough'
        num = 4;
end
end
