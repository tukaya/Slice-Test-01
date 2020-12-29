
namespace SliceTest01Library
{
    class A
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
