using System;
using Xunit;

namespace ReleaseContainerSample.Tests
{
    public class CalculatorTests
    {
        [Theory]
        [InlineData(1, 2, 3)]
        [InlineData(1, 0, 1)]
        [InlineData(0, 1, 1)]
        [InlineData(1, -1, 0)]
        public void AddTests(int x, int y, int sum)
        {
            Assert.Equal(Calculator.Add(x, y), sum);
        }
    }
}
