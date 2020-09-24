Poco Build Script
=================

Simple build script for Poco C++ library. Supports build for Android, iOS and Mac OS.

## Add-on

Simplify build and support latest platform,  for Android/iOS platform. 

### Enviromnent

* Xcode: 12.0
* NDK: 21.3
* Cmake: 3.10.2

### Android

```shell script
# Usage
./build_android.sh $ANDROID_CMAKE_HOME $POCO_REPO_ROOT_DIR $OPENSSL_ROOT_DIR

# Example
./build_android.sh ～/Library/Android/sdk/cmake/3.10.2.4988404 / 
~/Workspace/libs/poco /
~/Workspace/cos-sdk-repos/cos-cpp-sdk-v5/libs/openssl

# build output is in $PWD/Build/Android
```

### iOS

```shell script
# Usage
./build_ios.sh $iOS_VERSION $POCO_REPO_ROOT_DIR

# Example
./build_ios.sh 9.0 ~/Workspace/libs/poco

# build output is in $PWD/Build/iOS
```

## Original

### Usage:

	build.sh pocoVer iOS_Ver (ALL|Mobile|iOS|Android|MacOS) [CLEAN|CLEAN-ONLY]
		e.g ./build.sh 1.4.6p 6.1 Mobile CLEAN 
		
	The output in build/

### Important:
	
	Depends on Xcode's build system (see Platform/iOS/build_ios.sh) and Android's NDK ( you can add a standalone toolchain like the one in Platform/Android/toolchain/bin to your PATH).


Poco C++ Library: [http://pocoproject.org/](http://pocoproject.org/)

Android NDK: [http://developer.android.com/tools/sdk/ndk/index.html](http://developer.android.com/tools/sdk/ndk/index.html)

Xcode: [https://developer.apple.com/xcode/](https://developer.apple.com/xcode/)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/aksalj/poco/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

