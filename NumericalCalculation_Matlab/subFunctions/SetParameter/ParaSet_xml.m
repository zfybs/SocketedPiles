function OriginalParameters = ParaSet_xml(filePath)
%这个函数用来保存在 xml 文档中原始计算参数
% 

xmlStruct = xml_read(filePath);

% 桩截面定义 ：M_EIs  为一个结构体列向量，其中每一个元素为一个桩截面定义中所对应的信息
SectionDefinitions = ConstructShaftSections(xmlStruct.SectionDefinitions,xmlStruct.SystemProperty.ATTRIBUTE);

% 将桩进行分段，并匹配对应的土层信息
OriginalParameters = ParaSet_Sss(xmlStruct,SectionDefinitions);
