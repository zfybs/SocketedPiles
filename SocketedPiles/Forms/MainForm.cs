using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
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
        /// <summary> 模型画板 </summary>
        private SssDrawing _drawing;


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
            _drawing = new SssDrawing(_pictureBoxSystem);

            // 表格
            ConstructdataGridViewShaft();
            ConstructdataGridViewSoilLayers();

            //
            // 事件绑定
            dataGridViewSoilLayers.DataError += DataGridViewSoilLayersOnDataError;
            dataGridViewShaft.DataError += DataGridViewShaftOnDataError;

            // 绘图事件
            dataGridViewSoilLayers.CellValueChanged += DataGridViewSoilLayersOnCellValueChanged;
            dataGridViewShaft.CellValueChanged += DataGridViewShaftOnCellValueChanged;
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



        #endregion

        #region ---  PictureBox 绘图界面的刷新

        // 引发绘图操作的各种事件
        private void DataGridViewSoilLayersOnCellValueChanged(object sender, DataGridViewCellEventArgs dataGridViewCellEventArgs)
        {
            RefreshPaintingWithSss(_sss);
        }

        private void DataGridViewShaftOnCellValueChanged(object sender, DataGridViewCellEventArgs dataGridViewCellEventArgs)
        {
            RefreshPaintingWithSss(_sss);
        }

        // 绘图
        private void RefreshPaintingWithSss(SocketedShaftSystem sss)
        {
            _drawing.Draw(_sss);
        }

        // 保存
        private void buttonSavePicture_Click(object sender, EventArgs e)
        {
            string filePath = Utils.ChooseSaveEmf("将模型导出为矢量图");
            if (filePath.Length > 0)
            {
                _drawing.Save(filePath, _sss);
            }
        }

        #endregion

        #region ---  整个模型与 xml 文档 的导入导出
        /// <summary> 将整个模型导出到 xml 文档 </summary>
        private void buttonExportToXML_Click(object sender, EventArgs e)
        {
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
                //
                this.RefreshModel(sss);
                // 绘图
                RefreshPaintingWithSss(_sss);
            }
            catch (Exception ex)
            {
                DebugUtils.ShowDebugCatch(ex, "指定的文件不能正常导入为嵌岩桩模型。");
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

        private void buttonShaft_Click(object sender, EventArgs e)
        {
            AddDefinition<SocketedShaft> dds = new AddDefinition<SocketedShaft>(_sss.SocketedShaft);
            dds.ShowDialog();
        }


    }
}