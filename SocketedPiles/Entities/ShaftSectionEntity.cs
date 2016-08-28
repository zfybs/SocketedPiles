using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using SocketedShafts.Definitions;

namespace SocketedShafts.Entities
{
    /// <summary> 一根桩的一小截桩段 </summary>
    [Serializable()]
    public class ShaftSectionEntity
    {
        #region ---   Properties

        // 基本信息

        /// <summary> 此一小段桩的顶部绝对标高 </summary>
        [XmlAttribute()]
        public Single Top { get; set; }

        /// <summary> 此一小段桩的底部绝对标高 </summary>
        [XmlAttribute()]
        public Single Bottom { get; set; }

        /// <summary> 此一小段桩的截面信息 </summary>
        [XmlElement()]
        public ShaftSection Section { get; set; }
        #endregion


        /// <summary> 构造函数 </summary>
        public ShaftSectionEntity()
        {
        }
    }
}