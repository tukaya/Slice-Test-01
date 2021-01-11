
namespace SliceTest01Library
{
    interface IA
    {
        void Method1();
    }

    class A : IA
    {
        public void Method1()
        {

            Method2();
        }

        private void Method2()
        {
            // ...
            var b = new B();
            var bar = b.Bar();
        }
    }
}
