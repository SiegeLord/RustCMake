extern crate cmake_test;

/// This is a function inside the example 1.
pub fn example_function()
{
	println!("Testing example 1...\n");
}

#[test]
fn example_test()
{
	example_function();
}

#[cfg(not(test))]
fn main()
{
	cmake_test::other::test();
} 
