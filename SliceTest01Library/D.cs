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
