function OriginalParameters = ParaSet_xml(filePath)
%����������������� xml �ĵ���ԭʼ�������
% 

xmlStruct = xml_read(filePath);

% ׮���涨�� ��M_EIs  Ϊһ���ṹ��������������ÿһ��Ԫ��Ϊһ��׮���涨��������Ӧ����Ϣ
SectionDefinitions = ConstructShaftSections(xmlStruct.SectionDefinitions,xmlStruct.SystemProperty.ATTRIBUTE);

% ��׮���зֶΣ���ƥ���Ӧ��������Ϣ
OriginalParameters = ParaSet_Sss(xmlStruct,SectionDefinitions);
