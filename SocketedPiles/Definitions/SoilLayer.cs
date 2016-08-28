using System;
using System.ComponentModel;
using System.Xml.Serialization;

namespace SocketedShafts.Definitions
{
    /// <summary> 水中桩段或者嵌岩桩段的截面参数 </summary>
    [Serializable()]
    public class SoilLayer : Definition, ICloneable
    {
        #region ---   XmlAttribute
        
        [XmlAttribute()]
        [Category(Categories.Tag), Description("土层类型")]
        public SoilType Type { get; set; }

        [XmlAttribute()]
        [Category(Categories.Property), Description("岩石扰动程度，其值为[0,1]，0表示未扰动")]
        public float Disturbance { get; set; }

        [XmlAttribute()]
        [Category(Categories.Property), Description("有效重度，单位为 N/m3")]
        public float EffectiveUnitWeight { get; set; }

        [Category(Categories.Rock), Description("")]
        [XmlAttribute()]
        public float mi { get; set; }

        [XmlAttribute()]
        [Category(Categories.Rock), Description("Geological strength index")]
        public float GSI { get; set; }

        [XmlAttribute()]
        [Category(Categories.Rock), Description("无侧限抗压强度，单位为 Pa")]
        public float CompressiveStrength { get; set; }

        [XmlAttribute()]
        [Category(Categories.Sand), Description("有效摩擦角，单位为 度")]
        public float EffectiveFrictionAngle { get; set; }

        [XmlAttribute()]
        [Category(Categories.Clay), Description()]
        public float J { get; set; }

        [XmlAttribute()]
        [Category(Categories.Clay), Description("不排水剪切强度")]
        public float CU { get; set; }


        #endregion

        #region ---   构造函数

        public SoilLayer()
        {
        }

        public object Clone()
        {
            return MemberwiseClone();
        }

        #endregion
    }
}