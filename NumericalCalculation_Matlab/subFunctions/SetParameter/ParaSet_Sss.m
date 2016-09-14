function OriginalParameters = ParaSet_Sss(sss,SectionDefinitions)
% ParaSet_Sss, sss 即指 SocketedShaftSystem
% 输入参数：
%       SectionDefinitions ： 整个系统中所有的桩截面定义

%
soilLayers = sss.SoilLayers.SoilLayerEntity ; %% 土层的分层
shaftSections = sss.SocketedShaft.Sections.ShaftSectionEntity; %% 桩的分段

% 提取桩与土层的分段信息
[sectionBoundarys, sectionGuids] = GetSectionEntities(shaftSections);
[soilBoundarys, soilGuids] = GetSoilEntities(soilLayers);
soilTop = soilBoundarys(1,1);
shaftTop = sectionBoundarys(1,1);
shaftBottom =  sectionBoundarys(end,2);

% 水中桩段的处理
lw = shaftTop - soilTop;
if lw >=0
    waterSectionGuid =  sectionGuids{1};
    waterSectionDefinition = MatchSectionWithGuid(SectionDefinitions,waterSectionGuid);
    class_pileType_Water=PileType(waterSectionDefinition.Name,waterSectionDefinition.BendingMoment,waterSectionDefinition.BendingStiffness);
end

% 将土层根据桩的分段进行进一步地细分

soilSeperators=[ soilBoundarys(:,1);soilBoundarys(end,2)];
sectionSeperators = [sectionBoundarys(:,1);sectionBoundarys(end,2)];
subdivision = SortAndDiscardDuplicate([soilSeperators;sectionSeperators]);
% 只取土中有桩截面的那一段来进行有限差分计算
soilSeperators = subdivision(subdivision<=soilTop & subdivision >= shaftBottom);
nlayer = length(soilSeperators)-1;  % 最终确定的土层数量

%% 为每一个用来计算的小土层（小桩段）提取对应的土层参数以及桩截面参数
% 通过确定这一小分段的中点的标高位于哪一个桩段与土层的小区域中
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
    % 桩段截面定义
    sectionGuidIndex = IndexOf(sectionBoundarys, middlePoint);
    sectionDefinition = MatchSectionWithGuid(SectionDefinitions,sectionGuids{sectionGuidIndex});
    % 土层参数定义
    soilGuidIndex = IndexOf(soilBoundarys, middlePoint);
    soilDefinition = MatchSoilWithGuid(sss.SoilDefinitions,soilGuids{soilGuidIndex});
    
    % 对这一小层的各种参数进行赋值
    earthType(i) =  convertSoilType( soilDefinition.Type);
    class_pileType{i} = PileType(sectionDefinition.Name,sectionDefinition.BendingMoment,sectionDefinition.BendingStiffness);
    GSI      (i) =   soilDefinition.GSI;
    J        (i) =   soilDefinition.J;
    cu       (i) =   soilDefinition.CU;
    e1       (i) =   soilDefinition.E1 * 1e6;  % 将 MPa 转换为 Pa
    e2       (i) =   soilDefinition.E2 * 1e6;  % 将 MPa 转换为 Pa
    epip     (i) =   sectionDefinition.BendingStiffness(1);
    l        (i) =   soilSeperators(i) - soilSeperators(i+1);
    mi       (i) =   soilDefinition.mi;
    phieff   (i) =   soilDefinition.EffectiveFrictionAngle;
    reff     (i) =   soilDefinition.EffectiveUnitWeight;
    sigma_c  (i) =   soilDefinition.CompressiveStrength;
    v        (i) =   soilDefinition.PoissonRatio;
end

% 将所有的参数写入一个类中
OriginalParameters = OriginalProjectParameters(sss.SocketedShaft.ATTRIBUTE.Name ,earthType,GSI,J,R,cu,e1,e2,epip,l,lw, ...
    mi,nlayer,phieff,reff,sigma_c,v,class_pileType,class_pileType_Water);
end

%%
function sorted = SortAndDiscardDuplicate(Array)
% 将向量中的数值从大到小排列，并清除掉其中的相同值
sorted=sort(Array,'descend');
b = sorted(1:end-1) == sorted(2:end);
sorted(b)=[];
end

%% 在一列从大到小排列的数组中，找到某一个标高值所在的位置
function index = IndexOf(elevationArray, middleElev)
a = ( elevationArray(:,1)>middleElev) & elevationArray(:,2)<middleElev;
index = find(a);
end

%%
% 获取每一个桩段的上下标高，以及对应的截面定义的名称
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

% 获取每一个土层段的上下标高，以及对应的土层参数定义的GUID值
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
