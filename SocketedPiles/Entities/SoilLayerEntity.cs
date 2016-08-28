using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using SocketedShafts.Definitions;

namespace SocketedShafts.Entities
{
    /// <summary> 某具体的一段土层的信息 </summary>
    [Serializable()]
    public class SoilLayerEntity
    {
        #region ---   Properties

        // 基本信息

        /// <summary> 土层的顶部绝对标高 </summary>
        [XmlAttribute()]
        public Single Top { get; set; }

        /// <summary> 土层的底部绝对标高 </summary>
        [XmlAttribute()]
        public Single Bottom { get; set; }

        private SoilLayer _layer;
        /// <summary> 这一段土层的材料信息 </summary>
        [XmlElement()]
        public SoilLayer Layer
        {
            get { return _layer; }
            set { _layer = value; }
        }

        #endregion

        /// <summary> 构造函数 </summary>
        public SoilLayerEntity()
        {
        }
    }
}