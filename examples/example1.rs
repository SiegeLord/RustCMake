#[crate_id="example1"];

extern crate test;

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

fn main()
{
	test::other::test();
} 
