#![crate_id="example2"]

extern crate test = "test#0.1";

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
	test::other::test();
} 
