using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Serialization;
using eZstd.Miscellaneous;
using eZstd.UserControls;
using SocketedShafts.Definitions;
using SocketedShafts.Entities;
using SocketedShafts.Forms;

namespace SocketedShafts.Forms
{
    internal partial class MainForm : Form
    {
        #region ---   Fields

        private SocketedShaftSystem _sss;
        /// <summary> 整个模型中每一个具体土层的信息 </summary>
        private BindingList<SoilLayerEntity> _soilLayers;
        /// <summary> 整个模型中每一个具体桩截面的信息 </summary>
        private BindingList<ShaftSectionEntity> _shaftSections;

        #endregion

        #region ---   构造函数

        public MainForm()
        {
            InitializeComponent();

            //

            // 表格
            ConstructdataGridViewShaft();
            ConstructdataGridViewSoilLayers();

            // 事件绑定
            dataGridViewSoilLayers.DataError += DataGridViewSoilLayersOnDataError;
            dataGridViewShaft.DataError += DataGridViewShaftOnDataError;
            //
    
        }



        public void RefreshModel(SocketedShaftSystem sss)
        {
            _sss = sss;
            //
            //
            RefreshdataGridViewSoilLayers(sss);
            RefreshdataGridViewShaft(sss);
            //
        _soilLayers.AddingNew += SoilLayersOnAddingNew;
            _shaftSections.AddingNew += ShaftSectionsOnAddingNew;

        }

        #endregion

        #region ---   界面操作

        private void buttonSoilManager_Click(object sender, EventArgs e)
        {
            DefinitionManager<SoilLayer> dm = new DefinitionManager<SoilLayer>(_sss.SoilDefinitions);
            dm.ShowDialog();
            // 刷新表格界面
            RefreshComboBox(ColumnSoil, _sss.SoilDefinitions);
        }

        private void buttonSectionManager_Click(object sender, EventArgs e)
        {
            DefinitionManager<ShaftSection> dm = new DefinitionManager<ShaftSection>(_sss.SectionDefinitions);
            dm.ShowDialog();
            // 刷新表格界面
            RefreshComboBox(ColumnSegment, _sss.SectionDefinitions);
        }

        private void buttonSystemProperty_Click(object sender, EventArgs e)
        {
            var s = _sss.SystemProperty;
            AddDefinition<SystemProperty> ads = new AddDefinition<SystemProperty>(s);
            ads.ShowDialog();
        }

        /// <summary> 将整个模型导出到 xml 文档 </summary>
        private void buttonExportToXML_Click(object sender, EventArgs e)
        {
            ExportToXml(_sss, "../2.sss");
            return;
            string filePath = Utils.ChooseSaveSSS("导出水平受荷嵌岩桩文件");
            if (filePath.Length > 0)
            {
                // "../2.sss"
                ExportToXml(_sss, filePath);
            }
        }

        /// <summary> 从 xml 文档导入整个模型信息 </summary>
        private void buttonImportFromXML_Click(object sender, EventArgs e)
        {
            string filePath = Utils.ChooseOpenSSS("导入水平受荷嵌岩桩文件");
            if (filePath.Length > 0)
            {
                // "../2.sss"
                ImportFromXml(filePath);
            }
        }

        #endregion

        #region ---  PictureBox 绘图界面的刷新

        #endregion

        #region ---  整个模型与 xml 文档 的导入导出


        /// <summary>
        /// 
        /// </summary>
        /// <param name="filePath">此路径必须为一个有效的路径</param>
        private void ImportFromXml(string filePath)
        {
            try
            {
                //
                XmlReader xr = XmlReader.Create(filePath);
                //
                XmlSerializer ss = new XmlSerializer(typeof(SocketedShaftSystem));
                SocketedShaftSystem sss = (SocketedShaftSystem)ss.Deserialize(xr);
                xr.Close();

                // 同步到全局
                SocketedShaftSystem.SetUniqueInstance(sss);
                this.RefreshModel(sss);
            }
            catch (Exception ex)
            {
                DebugUtils.ShowDebugCatch(ex, "");
            }
        }

        /// <param name="filePath">此路径必须为一个有效的路径</param>
        private void ExportToXml(SocketedShaftSystem sss, string filePath)
        {
            try
            {
                FileStream fs = new FileStream(filePath, FileMode.OpenOrCreate);

                XmlSerializer s = new XmlSerializer(sss.GetType());
                s.Serialize(fs, sss);
                fs.Close();
            }
            catch (Exception ex)
            {
                DebugUtils.ShowDebugCatch(ex, "");
            }

        }

        #endregion
    }
}