using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SliceTest01Library
{
    class D
    {
        private readonly IA a;

        public D(IA a)
        {
            this.a = a;
        }

        public void DoSomething()
        {
            a.Method1();
        }
    }
}
