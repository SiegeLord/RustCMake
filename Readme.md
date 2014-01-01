An example of using CMake with Rust.

Try it!
~~~
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp
make -j
make test -j
make doc -j
make install

cd examples
./example1
./example2
~~~
