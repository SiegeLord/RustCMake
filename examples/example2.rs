extern crate cmake_test;

/// This is a function inside the example 2.
pub fn example_function()
{
	println!("Testing example 2...\n");
}

#[test]
fn example_test()
{
	example_function();
}

fn main()
{
	cmake_test::other::test();
} 
