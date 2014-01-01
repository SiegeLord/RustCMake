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

License:

The example files are released into the public domain, and the CMake modules are licensed under the zlib license (see file contents).
