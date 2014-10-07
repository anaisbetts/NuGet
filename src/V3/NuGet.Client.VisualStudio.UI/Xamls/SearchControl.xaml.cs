﻿using System;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Threading;

namespace NuGet.Client.VisualStudio.UI
{
    /// <summary>
    /// Interaction logic for SearchControl.xaml
    /// </summary>
    public partial class SearchControl : UserControl
    {
        private DispatcherTimer _timer;

        public SearchControl()
        {
            _timer = new DispatcherTimer();
            _timer.Interval = TimeSpan.FromMilliseconds(1000);

            _timer.Tick += (sender, e) =>
            {
                _timer.Stop();
                if (SearchStart != null)
                {
                    SearchStart(this, EventArgs.Empty);
                }                
            };
            InitializeComponent();
        }

        public event EventHandler<EventArgs> SearchStart;

        public string Text
        {
            get
            {
                return _textBox.Text;
            }
            set
            {
                _textBox.Text = value;
            }
        }

        private void _textBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            _timer.Start();
        }

        private void _textBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                if (SearchStart != null)
                {
                    SearchStart(this, EventArgs.Empty);
                }
            }
        }
    }
}
