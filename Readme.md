An example of using CMake with Rust (using not yet merged changes!).

Try it!
~~~
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp
make -j
make test
make doc -j
sudo make install

cd examples
./example1
./example2
~~~
