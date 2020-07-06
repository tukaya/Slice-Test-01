using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SliceTest01Library
{
    class B
    {
        public string Bar()
        {
            var a = new A();
            a.Method1();
            a.Method1();
            return "";
        }
    }
}
