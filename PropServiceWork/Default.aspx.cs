using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebPush;

namespace PropServiceWork
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var vapidKeys = VapidHelper.GenerateVapidKeys();
            Console.WriteLine("Public Key: " + vapidKeys.PublicKey);
            Console.WriteLine("Private Key: " + vapidKeys.PrivateKey);

        }
    }
}