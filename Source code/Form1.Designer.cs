namespace ImageScaling
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.BmpPath = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.LoadBitmap = new System.Windows.Forms.Button();
            this.OpenFileDIalogBitmap = new System.Windows.Forms.OpenFileDialog();
            this.label2 = new System.Windows.Forms.Label();
            this.LoadedImage = new System.Windows.Forms.PictureBox();
            this.LoadedImageBox = new System.Windows.Forms.GroupBox();
            this.Coption = new System.Windows.Forms.RadioButton();
            this.ASMoption = new System.Windows.Forms.RadioButton();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.LoadedBoxInfo = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.NewHeightBox = new System.Windows.Forms.TextBox();
            this.NewWidthBox = new System.Windows.Forms.TextBox();
            this.GenerateButton = new System.Windows.Forms.Button();
            this.GeneratedImageBox = new System.Windows.Forms.GroupBox();
            this.GeneratedImage = new System.Windows.Forms.PictureBox();
            this.GeneratedBoxInfo = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.SaveButton = new System.Windows.Forms.Button();
            this.SavePath = new System.Windows.Forms.TextBox();
            this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
            this.label7 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.threadsSlider = new System.Windows.Forms.TrackBar();
            this.label10 = new System.Windows.Forms.Label();
            this.minThreadsValue = new System.Windows.Forms.Label();
            this.maxThreadsValue = new System.Windows.Forms.Label();
            this.numberOfThreads = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.LoadedImage)).BeginInit();
            this.LoadedImageBox.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.GeneratedImageBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.GeneratedImage)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.threadsSlider)).BeginInit();
            this.SuspendLayout();
            // 
            // BmpPath
            // 
            this.BmpPath.Enabled = false;
            this.BmpPath.Location = new System.Drawing.Point(59, 50);
            this.BmpPath.Name = "BmpPath";
            this.BmpPath.ReadOnly = true;
            this.BmpPath.Size = new System.Drawing.Size(282, 22);
            this.BmpPath.TabIndex = 0;
            this.BmpPath.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(161, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(103, 17);
            this.label1.TabIndex = 1;
            this.label1.Text = "Choose Bitmap";
            // 
            // LoadBitmap
            // 
            this.LoadBitmap.Location = new System.Drawing.Point(347, 46);
            this.LoadBitmap.Name = "LoadBitmap";
            this.LoadBitmap.Size = new System.Drawing.Size(86, 30);
            this.LoadBitmap.TabIndex = 2;
            this.LoadBitmap.Text = "Browse...";
            this.LoadBitmap.UseVisualStyleBackColor = true;
            this.LoadBitmap.Click += new System.EventHandler(this.LoadBitmap_Click);
            // 
            // OpenFileDIalogBitmap
            // 
            this.OpenFileDIalogBitmap.FileName = "*.bmp";
            this.OpenFileDIalogBitmap.FileOk += new System.ComponentModel.CancelEventHandler(this.OpenFileDIalogBitmap_FileOk);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 53);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(41, 17);
            this.label2.TabIndex = 3;
            this.label2.Text = "Path:";
            // 
            // LoadedImage
            // 
            this.LoadedImage.Location = new System.Drawing.Point(6, 21);
            this.LoadedImage.Name = "LoadedImage";
            this.LoadedImage.Size = new System.Drawing.Size(411, 261);
            this.LoadedImage.TabIndex = 4;
            this.LoadedImage.TabStop = false;
            this.LoadedImage.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // LoadedImageBox
            // 
            this.LoadedImageBox.Controls.Add(this.LoadedImage);
            this.LoadedImageBox.Location = new System.Drawing.Point(10, 88);
            this.LoadedImageBox.Name = "LoadedImageBox";
            this.LoadedImageBox.Size = new System.Drawing.Size(423, 288);
            this.LoadedImageBox.TabIndex = 5;
            this.LoadedImageBox.TabStop = false;
            this.LoadedImageBox.Text = "Loaded image";
            this.LoadedImageBox.Enter += new System.EventHandler(this.LoadedImageBox_Enter);
            // 
            // Coption
            // 
            this.Coption.AutoSize = true;
            this.Coption.Location = new System.Drawing.Point(99, 27);
            this.Coption.Name = "Coption";
            this.Coption.Size = new System.Drawing.Size(38, 21);
            this.Coption.TabIndex = 7;
            this.Coption.Text = "C";
            this.Coption.UseVisualStyleBackColor = true;
            this.Coption.CheckedChanged += new System.EventHandler(this.radioButton2_CheckedChanged);
            // 
            // ASMoption
            // 
            this.ASMoption.AutoSize = true;
            this.ASMoption.Checked = true;
            this.ASMoption.Location = new System.Drawing.Point(30, 27);
            this.ASMoption.Name = "ASMoption";
            this.ASMoption.Size = new System.Drawing.Size(58, 21);
            this.ASMoption.TabIndex = 8;
            this.ASMoption.TabStop = true;
            this.ASMoption.Text = "ASM";
            this.ASMoption.UseVisualStyleBackColor = true;
            this.ASMoption.CheckedChanged += new System.EventHandler(this.radioButton3_CheckedChanged);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.ASMoption);
            this.groupBox1.Controls.Add(this.Coption);
            this.groupBox1.Location = new System.Drawing.Point(526, 195);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(166, 65);
            this.groupBox1.TabIndex = 9;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Choose DLL";
            this.groupBox1.Enter += new System.EventHandler(this.groupBox1_Enter);
            // 
            // LoadedBoxInfo
            // 
            this.LoadedBoxInfo.BackColor = System.Drawing.SystemColors.MenuBar;
            this.LoadedBoxInfo.Location = new System.Drawing.Point(12, 399);
            this.LoadedBoxInfo.Multiline = true;
            this.LoadedBoxInfo.Name = "LoadedBoxInfo";
            this.LoadedBoxInfo.ReadOnly = true;
            this.LoadedBoxInfo.Size = new System.Drawing.Size(421, 68);
            this.LoadedBoxInfo.TabIndex = 10;
            this.LoadedBoxInfo.Text = "No image loaded.";
            this.LoadedBoxInfo.TextChanged += new System.EventHandler(this.textBox1_TextChanged_1);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(13, 379);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(73, 17);
            this.label3.TabIndex = 11;
            this.label3.Text = "Image info";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(512, 126);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(82, 17);
            this.label4.TabIndex = 12;
            this.label4.Text = "New height:";
            this.label4.Click += new System.EventHandler(this.label4_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(512, 157);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(75, 17);
            this.label5.TabIndex = 13;
            this.label5.Text = "New width:";
            this.label5.Click += new System.EventHandler(this.label5_Click);
            // 
            // NewHeightBox
            // 
            this.NewHeightBox.Location = new System.Drawing.Point(600, 126);
            this.NewHeightBox.Name = "NewHeightBox";
            this.NewHeightBox.Size = new System.Drawing.Size(92, 22);
            this.NewHeightBox.TabIndex = 14;
            this.NewHeightBox.TextChanged += new System.EventHandler(this.NewHeightBox_TextChanged);
            // 
            // NewWidthBox
            // 
            this.NewWidthBox.Location = new System.Drawing.Point(600, 157);
            this.NewWidthBox.Name = "NewWidthBox";
            this.NewWidthBox.Size = new System.Drawing.Size(92, 22);
            this.NewWidthBox.TabIndex = 15;
            // 
            // GenerateButton
            // 
            this.GenerateButton.Location = new System.Drawing.Point(556, 365);
            this.GenerateButton.Name = "GenerateButton";
            this.GenerateButton.Size = new System.Drawing.Size(107, 29);
            this.GenerateButton.TabIndex = 16;
            this.GenerateButton.Text = "Generate";
            this.GenerateButton.UseVisualStyleBackColor = true;
            this.GenerateButton.Click += new System.EventHandler(this.GenerateButton_Click);
            // 
            // GeneratedImageBox
            // 
            this.GeneratedImageBox.Controls.Add(this.GeneratedImage);
            this.GeneratedImageBox.Location = new System.Drawing.Point(784, 88);
            this.GeneratedImageBox.Name = "GeneratedImageBox";
            this.GeneratedImageBox.Size = new System.Drawing.Size(423, 288);
            this.GeneratedImageBox.TabIndex = 17;
            this.GeneratedImageBox.TabStop = false;
            this.GeneratedImageBox.Text = "Generated image";
            // 
            // GeneratedImage
            // 
            this.GeneratedImage.Location = new System.Drawing.Point(6, 21);
            this.GeneratedImage.Name = "GeneratedImage";
            this.GeneratedImage.Size = new System.Drawing.Size(411, 261);
            this.GeneratedImage.TabIndex = 4;
            this.GeneratedImage.TabStop = false;
            // 
            // GeneratedBoxInfo
            // 
            this.GeneratedBoxInfo.BackColor = System.Drawing.SystemColors.MenuBar;
            this.GeneratedBoxInfo.Location = new System.Drawing.Point(780, 399);
            this.GeneratedBoxInfo.Multiline = true;
            this.GeneratedBoxInfo.Name = "GeneratedBoxInfo";
            this.GeneratedBoxInfo.ReadOnly = true;
            this.GeneratedBoxInfo.Size = new System.Drawing.Size(421, 68);
            this.GeneratedBoxInfo.TabIndex = 18;
            this.GeneratedBoxInfo.Text = "No image generated.";
            this.GeneratedBoxInfo.TextChanged += new System.EventHandler(this.GeneratedBoxInfo_TextChanged);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(781, 379);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(73, 17);
            this.label6.TabIndex = 19;
            this.label6.Text = "Image info";
            // 
            // SaveButton
            // 
            this.SaveButton.Location = new System.Drawing.Point(1132, 46);
            this.SaveButton.Name = "SaveButton";
            this.SaveButton.Size = new System.Drawing.Size(75, 30);
            this.SaveButton.TabIndex = 20;
            this.SaveButton.Text = "Save";
            this.SaveButton.UseVisualStyleBackColor = true;
            this.SaveButton.Click += new System.EventHandler(this.button1_Click);
            // 
            // SavePath
            // 
            this.SavePath.Location = new System.Drawing.Point(875, 50);
            this.SavePath.Name = "SavePath";
            this.SavePath.Size = new System.Drawing.Size(251, 22);
            this.SavePath.TabIndex = 21;
            this.SavePath.TextChanged += new System.EventHandler(this.SavePath_TextChanged);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(796, 53);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(73, 17);
            this.label7.TabIndex = 20;
            this.label7.Text = "FIle name:";
            this.label7.Click += new System.EventHandler(this.label7_Click);
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(953, 19);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(82, 17);
            this.label8.TabIndex = 20;
            this.label8.Text = "Save image";
            this.label8.Click += new System.EventHandler(this.label8_Click);
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(523, 88);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(169, 17);
            this.label9.TabIndex = 22;
            this.label9.Text = "Set new size of the image";
            this.label9.Click += new System.EventHandler(this.label9_Click);
            // 
            // threadsSlider
            // 
            this.threadsSlider.Location = new System.Drawing.Point(515, 292);
            this.threadsSlider.Minimum = 1;
            this.threadsSlider.Name = "threadsSlider";
            this.threadsSlider.Size = new System.Drawing.Size(188, 56);
            this.threadsSlider.TabIndex = 23;
            this.threadsSlider.Value = 1;
            this.threadsSlider.Scroll += new System.EventHandler(this.trackBar1_Scroll);
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(521, 272);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(158, 17);
            this.label10.TabIndex = 24;
            this.label10.Text = "Pick number of threads:";
            this.label10.Click += new System.EventHandler(this.label10_Click);
            // 
            // minThreadsValue
            // 
            this.minThreadsValue.AutoSize = true;
            this.minThreadsValue.Location = new System.Drawing.Point(523, 317);
            this.minThreadsValue.Name = "minThreadsValue";
            this.minThreadsValue.Size = new System.Drawing.Size(16, 17);
            this.minThreadsValue.TabIndex = 25;
            this.minThreadsValue.Text = "1";
            // 
            // maxThreadsValue
            // 
            this.maxThreadsValue.AutoSize = true;
            this.maxThreadsValue.Location = new System.Drawing.Point(679, 317);
            this.maxThreadsValue.Name = "maxThreadsValue";
            this.maxThreadsValue.Size = new System.Drawing.Size(0, 17);
            this.maxThreadsValue.TabIndex = 26;
            this.maxThreadsValue.Click += new System.EventHandler(this.label12_Click);
            // 
            // numberOfThreads
            // 
            this.numberOfThreads.AutoSize = true;
            this.numberOfThreads.Location = new System.Drawing.Point(676, 272);
            this.numberOfThreads.Name = "numberOfThreads";
            this.numberOfThreads.Size = new System.Drawing.Size(16, 17);
            this.numberOfThreads.TabIndex = 27;
            this.numberOfThreads.Text = "1";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(1278, 491);
            this.Controls.Add(this.numberOfThreads);
            this.Controls.Add(this.maxThreadsValue);
            this.Controls.Add(this.minThreadsValue);
            this.Controls.Add(this.label10);
            this.Controls.Add(this.threadsSlider);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.SaveButton);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.label8);
            this.Controls.Add(this.SavePath);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.GeneratedBoxInfo);
            this.Controls.Add(this.GeneratedImageBox);
            this.Controls.Add(this.GenerateButton);
            this.Controls.Add(this.NewWidthBox);
            this.Controls.Add(this.NewHeightBox);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.LoadedBoxInfo);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.LoadedImageBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.LoadBitmap);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.BmpPath);
            this.ImeMode = System.Windows.Forms.ImeMode.On;
            this.Name = "Form1";
            this.Text = "ImageScaling";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.LoadedImage)).EndInit();
            this.LoadedImageBox.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.GeneratedImageBox.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.GeneratedImage)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.threadsSlider)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox BmpPath;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button LoadBitmap;
        private System.Windows.Forms.OpenFileDialog OpenFileDIalogBitmap;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.PictureBox LoadedImage;
        private System.Windows.Forms.GroupBox LoadedImageBox;
        private System.Windows.Forms.RadioButton Coption;
        private System.Windows.Forms.RadioButton ASMoption;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox LoadedBoxInfo;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox NewHeightBox;
        private System.Windows.Forms.TextBox NewWidthBox;
        private System.Windows.Forms.Button GenerateButton;
        private System.Windows.Forms.GroupBox GeneratedImageBox;
        private System.Windows.Forms.PictureBox GeneratedImage;
        private System.Windows.Forms.TextBox GeneratedBoxInfo;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Button SaveButton;
        private System.Windows.Forms.TextBox SavePath;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.TrackBar threadsSlider;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label minThreadsValue;
        private System.Windows.Forms.Label maxThreadsValue;
        private System.Windows.Forms.Label numberOfThreads;
    }
}

