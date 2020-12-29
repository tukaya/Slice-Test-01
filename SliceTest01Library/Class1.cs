namespace SliceTest01Library
{
    class Class1
    {
        public Class1()
        {
            var foo = new Foo();
        }

        public void SomeMethod()
        {
            var x = new Foo().Bar();
            var b = new B();
            var bar = b.Bar();
            if (x == bar)
            { 
            
            }
        }
    }
}
