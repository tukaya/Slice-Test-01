namespace SliceTest01Library
{
    interface IX
    {
        void MethodX();
    }

    class X : IX
    {
        public void MethodX()
        {
            var y = new Y();
            y.MethodY();
        }
    }
}
