using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SocketedShafts.Forms
{
    /// <summary> 对整个系统中所有的土层或者桩截面进行管理 </summary>
    /// <typeparam name="T"></typeparam>
    public partial class DefinitionManager<T> : Form where T : ICloneable, new()
    {
        //public List<T> Definitions
        //{
        //    get { return _definitions.ToList(); }
        //}

        private readonly BindingList<T> _definitions;

        /// <summary> 进行管理的集合 </summary>
        /// <param name="definitions"></param>
        public DefinitionManager(IList<T> definitions)
        {
            InitializeComponent();
            //
            _definitions = new BindingList<T>(definitions);

            // 绑定到集合
            listBox1.DisplayMember = "Name";
            listBox1.DataSource = _definitions;
        }

        #region ---   添加、移除 与 编辑

        private void buttonAdd_Click(object sender, EventArgs e)
        {
            //
            AddDefinition<T> formAddDefinition = new AddDefinition<T>();
            var res = formAddDefinition.ShowDialog();
            if (res == DialogResult.OK)
            {
                _definitions.Add(formAddDefinition.Instance);
            }
        }

        private void buttonRemove_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex >= 0)
            {
                _definitions.RemoveAt(listBox1.SelectedIndex);
            }
        }

        private void buttonEdit_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex >= 0)
            {
                T item = (T)listBox1.SelectedItem;
                T itemClone = (T)item.Clone();
                //
                AddDefinition<T> formAddDefinition = new AddDefinition<T>(itemClone);
                var res = formAddDefinition.ShowDialog();
                if (res == DialogResult.OK)
                {
                    _definitions[listBox1.SelectedIndex] = formAddDefinition.Instance;
                }
            }
        }

        #endregion
    }
}