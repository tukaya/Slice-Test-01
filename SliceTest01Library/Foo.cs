namespace SliceTest01Library
{
    public class Foo
    {
        private string _bar = "";
        public string Bar()
        {
            var a = new A();
            a.Method1();
            a.Method1();
            return _bar;
        }

        private void SomeMethod(X x)
        {
            x.MethodX();
        }
    }
}
