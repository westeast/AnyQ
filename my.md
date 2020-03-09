## 启动
docker 

启动并进入docker

docker run --name brpc -it \
--privileged=true \
-p 8900:8900 -p 8999:8999 \
-p 8998:8998 -p 8997:8997 \
-v $HOME/git/rpc:/paddle \
-w /paddle \
westeast/lnmp-ubuntu:brpc  /bin/bash

docker start brpc

进入docker
docker exec -i -t brpc /bin/bash

只编译run_server
`cmake -DMIN_COMPILE=ON .. && make -j4 run_server `

重新编译所有
`cmake .. && make -j4 `



启动
1.启动solr，cd solr-4.10.3-anyq/example java -jar start.jar
2.导入初始数椐，http://127.0.0.1:8900/solr/admin.html solr管理页面  
3.step1+step2=>`./solr/anyq_solr.sh ./solr/sample_docs ./solr-4.10.3-anyq/` 最后一个参数是默认值也可以省略。
4.stop solr => `bash ./solr/solr_deply.sh stop ./solr-4.10.3-anyq/ 8900`
3.在build目录解压example配置文件，然后运行 ./run_server 可通过ip:8999/anyq?question=xxx来测试
参考：https://zhuanlan.zhihu.com/p/73590442


保存下自己的镜像：
docker commit -m 'paddle anyq brpc solr java c++' ae9624dee06c westeast/lnmp-ubuntu:brpc

简单压测：ab -k -n 100000 -c 10 http://127.0.0.1:8999/anyq?question=bbb

## build error
1 xgboost
```
[ 39%] Performing install step for 'extern_xgboost'
Makefile:31: MAKE [make] - checked OK
src/learner.cc: In member function ‘virtual void xgboost::LearnerImpl::SaveModel(xgboost::Json*) const’:
src/learner.cc:393:24: error: invalid initialization of non-const reference of type ‘xgboost::Json&’ from an rvalue of type ‘<brace-enclosed initializer list>’
     Json& out { *p_out };
                        ^
src/learner.cc: In member function ‘virtual void xgboost::LearnerImpl::SaveConfig(xgboost::Json*) const’:
src/learner.cc:455:24: error: invalid initialization of non-const reference of type ‘xgboost::Json&’ from an rvalue of type ‘<brace-enclosed initializer list>’
     Json& out { *p_out };
                        ^
Makefile:136: recipe for target 'build/learner.o' failed
make[3]: *** [build/learner.o] Error 1
make[3]: *** Waiting for unfinished jobs....
CMakeFiles/extern_xgboost.dir/build.make:73: recipe for target 'third_party/xgboost/src/extern_xgboost-stamp/extern_xgboost-install' failed
make[2]: *** [third_party/xgboost/src/extern_xgboost-stamp/extern_xgboost-install] Error 2
CMakeFiles/Makefile2:333: recipe for target 'CMakeFiles/extern_xgboost.dir/all' failed
make[1]: *** [CMakeFiles/extern_xgboost.dir/all] Error 2
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```
错误原因未知，找到下载的xgboost改成v0.81版本，重新 make就行了，彻底解决修改AnyQ/cmake/external下的xgboost.cmake下的line10改成DOWNLOAD_COMMAND git clone --recursive https://github.com/dmlc/xgboost.git && cd xgboost && git checkout v0.81 既可。



2. paddle build error
```
Makefile:105: recipe for target 'all' failed
make[3]: *** [all] Error 2
CMakeFiles/extern_paddle.dir/build.make:112: recipe for target 'third_party/paddle/src/extern_paddle-stamp/extern_paddle-build' failed
make[2]: *** [third_party/paddle/src/extern_paddle-stamp/extern_paddle-build] Error 2
CMakeFiles/Makefile2:441: recipe for target 'CMakeFiles/extern_paddle.dir/all' failed
make[1]: *** [CMakeFiles/extern_paddle.dir/all] Error 2
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```
进入了paddle目录重新编译：cd ./third_party/install/paddle/paddle  make -j1
```
paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/build.make:60: *** target pattern contains no '%'.  Stop.
CMakeFiles/Makefile2:2163: recipe for target 'paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/all' failed
make[1]: *** [paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/all] Error 2
Makefile:105: recipe for target 'all' failed
make: *** [all] Error 2

paddle/fluid/framework/CMakeFiles/framework_py_proto.dir/build.make:60: *** target pattern contains no '%'.  Stop.
CMakeFiles/Makefile2:2313: recipe for target 'paddle/fluid/framework/CMakeFiles/framework_py_proto.dir/all' failed
make[4]: *** [paddle/fluid/framework/CMakeFiles/framework_py_proto.dir/all] Error 2
make[4]: *** Waiting for unfinished jobs....
[  6%] Built target extern_eigen3
paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/build.make:60: *** target pattern contains no '%'.  Stop.
CMakeFiles/Makefile2:1469: recipe for target 'paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/all' failed
make[4]: *** [paddle/fluid/platform/CMakeFiles/profiler_py_proto.dir/all] Error 2
```
可能是cmake版本太老了： apt-get upgrade cmake ，这里说要cmake3.4 https://github.com/PaddlePaddle/Paddle/issues/6197  我的是3.1 直接安装了3.15,删除了build目录 重新编译。但还有上面的错误。
看了这个说是cmake版本高也有问题：https://blog.csdn.net/u011818766/article/details/104117469  所以cmake还是用3.4.0  https://cmake.org/files/v3.4/  
wget https://cmake.org/files/v3.4/cmake-3.4.0.tar.gz
./configure && make && make install  之后再编译总是内存不够导致编译器挂了，后进入paddle目录third_party/install/paddle里单独编译paddle make -j2成功，后返回anyq重新编译。


3 lac cmakelist
```
-- CXX compiler: /usr/bin/c++, version: GNU 4.8.5
-- C compiler: /usr/bin/cc, version: GNU 4.8.5
CMake Error at CMakeLists.txt:12 (message):
  A gcc compiler with a version >= 4.8.2 is needed.


-- Configuring incomplete, errors occurred!
See also "/paddle/AnyQ/build/third_party/lac/src/lac/CMakeFiles/CMakeOutput.log".
CMakeFiles/extern_lac.dir/build.make:111: recipe for target 'third_party/lac/src/extern_lac-stamp/extern_lac-build' failed
make[2]: *** [third_party/lac/src/extern_lac-stamp/extern_lac-build] Error 1
CMakeFiles/Makefile2:524: recipe for target 'CMakeFiles/extern_lac.dir/all' failed
make[1]: *** [CMakeFiles/extern_lac.dir/all] Error 2
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```
这个不知道 为啥版本判断错误了，直接把cmakeList中的error给注释了，重新 编译，这次全都 过了，anyq编译完成 。


