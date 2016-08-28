using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using eZstd.Data;

namespace SocketedShafts.Entities
{
    /// <summary> 一根嵌岩桩 </summary>
    [Serializable()]
    public class SocketedShaft
    {
        #region ---   Properties

        // 基本信息

        /// <summary> 桩顶（一般位于水面）所受的水平荷载，单位为 KN </summary>
        [XmlAttribute()]
        public Single HorizontalLoads { get; set; }

        /// <summary> 嵌岩桩的名称 </summary>
        [XmlAttribute()]
        public string Name { get; set; }

        /// <summary> 整根桩的所有截面集合（不区分水中与土层中，而将其看成是未安装前的一根桩） </summary>
        public XmlList<ShaftSectionEntity> Sections { get; set; }
        
        #endregion

        #region ---   构造函数

        /// <summary> 构造函数 </summary>
        public SocketedShaft()
        {
            Sections = new XmlList<ShaftSectionEntity>();
        }
        
        #endregion
    }
}