using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows.Forms;
using SocketedShafts.Definitions;

namespace SocketedShafts.Forms
{
    /// <summary> 对整个系统中所有的土层或者桩截面进行管理 </summary>
    /// <typeparam name="T"></typeparam>
    public partial class DefinitionManager<T> : Form where T : Definition, new()
    {
        private readonly BindingList<T> _definitions;

        /// <summary>构造函数</summary>
        /// <param name="definitions"> 进行管理的集合</param>
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
            T def = (T)formAddDefinition.Instance;
            if (res == DialogResult.OK)
            {
                string errorMessage;
                if (CheckAddDefinition(_definitions, def, out errorMessage))
                {
                    _definitions.Add((T)def);
                }
                else
                {
                    MessageBox.Show(errorMessage, "添加参数定义出错", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        /// <summary> 检查添加后的定义集合是否符合命名的唯一性规范 </summary>
        private bool CheckAddDefinition(BindingList<T> originaldefinitions, Definition defToAdd, out string errorMessage)
        {
            if (string.IsNullOrEmpty(defToAdd.Name))
            {
                errorMessage = "必须为添加的参数定义指定一个名称。";
                return false;
            }
            // 检查有没有重复的名称
            int namesCount = originaldefinitions.Count + 1;  // 如果添加成功的话，那整个集合中应该有这么多名称
            SortedSet<string> names = new SortedSet<string>();
            foreach (var def in originaldefinitions)
            {
                names.Add(def.Name);
            }
            names.Add(defToAdd.Name);
            if (names.Count < namesCount)
            {
                errorMessage = "新添加的参数定义与现有集合中的定义重名。";
                return false;
            }
            errorMessage = "成功";
            return true;
        }

        #endregion

        #region ---   编辑

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
                    string errorMessage;
                    if (CheckEditDefinition(_definitions, item, itemClone, out errorMessage))
                    {
                        _definitions[listBox1.SelectedIndex] = (T)formAddDefinition.Instance;
                    }
                    else
                    {
                        MessageBox.Show(errorMessage, "编辑参数定义出错", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }

        /// <summary> 检查编辑后的定义集合是否符合命名的唯一性规范 </summary>
        /// <param name="originaldefinitions"></param>
        /// <param name="defToEdit">被编辑的定义，此定义是位于 originaldefinitions 集合中的</param>
        /// <param name="editedDef">被编辑后的新的定义</param>
        /// <param name="errorMessage"></param>
        /// <returns></returns>
        private bool CheckEditDefinition(BindingList<T> originaldefinitions, Definition defToEdit, Definition editedDef,
            out string errorMessage)
        {
            if (string.IsNullOrEmpty(editedDef.Name))
            {
                errorMessage = "必须为当前参数定义指定一个名称。";
                return false;
            }
            // 先将新名称替换掉旧名称
            var index = originaldefinitions.IndexOf((T)defToEdit);
            var namesT = originaldefinitions.Select(r => r.Name).ToList();
            namesT[index] = editedDef.Name;
            //

            // 检查有没有重复的名称
            SortedSet<string> names = new SortedSet<string>();

            foreach (var n in namesT)
            {
                names.Add(n);
            }
            if (names.Count < namesT.Count)
            {
                errorMessage = "新添加的参数定义与现有集合中的定义重名。";
                return false;
            }
            errorMessage = "成功";
            return true;
        }

        #endregion

        private void buttonRemove_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex >= 0)
            {
                _definitions.RemoveAt(listBox1.SelectedIndex);
            }
        }
    }
}