using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SliceTest01Library
{
    class Z
    {
        private readonly IX x;

        public Z(IX x)
        {
            this.x = x;
        }

        public void ZMethod()
        {

            var y = new Y();
            y.MethodY();

            x.MethodX();
        }

    }
}
