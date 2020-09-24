#!/bin/sh

#  build_poco_android.sh
#
#

#===============================================================================
# Functions
#===============================================================================

doneSection()
{
echo
echo "    ================================================================="
echo "    Done"
echo
}

witeMessage()
{
echo
echo "    ================================================================="
echo "    $1"
echo "    ================================================================="
echo
}
#===============================================================================

if [ -z $ANDROID_HOME ]; then
    echo "Please set ANDROID_HOME in environment."
    exit 1
fi

ANDROID_CMAKE_HOME=$1
POCO=$2
OPEN_SSL_HOME=$3

BUILD_ROOT=$PWD/Build/Android
rm -fr $BUILD_ROOT
mkdir -p $BUILD_ROOT

cd $POCO

for ABI in {x86_64,x86,armeabi-v7a,arm64-v8a}
do
rm -fr /tmp/poco-build

witeMessage "Build for $ABI..."

$ANDROID_CMAKE_HOME/bin/cmake -H. \
-B/tmp/poco-build -G'Ninja' \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_MAKE_PROGRAM=$ANDROID_CMAKE_HOME/bin/ninja \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_HOME/ndk-bundle/build/cmake/android.toolchain.cmake \
-DANDROID_NATIVE_API_LEVEL=24 \
-DANDROID_ABI=$ABI  \
-DOPENSSL_INCLUDE_DIR=$OPEN_SSL_HOME/include  \
-DOPENSSL_CRYPTO_LIBRARY=$OPEN_SSL_HOME/$ABI/libcrypto.a  \
-DOPENSSL_SSL_LIBRARY=$OPEN_SSL_HOME/$ABI/libssl.a  \
-DENABLE_NETSSL=1  \
-DENABLE_DATA_SQLITE=0 \
-DENABLE_MONGODB=0  \
-DENABLE_ENCODINGS=0 \
-DENABLE_REDIS=0 \
-DENABLE_JWT=0 \
-DENABLE_ZIP=0 \
-DENABLE_PAGECOMPILER=0 \
-DENABLE_PAGECOMPILER_FILE2PAGE=0 \
-DBUILD_SHARED_LIBS=0

$ANDROID_CMAKE_HOME/bin/cmake --build /tmp/poco-build

mkdir -p $BUILD_ROOT/$ABI
cp -r /tmp/poco-build/lib/* $BUILD_ROOT/$ABI

witeMessage "$ABI static binary copyed to $BUILD_ROOT/$ABI"
done

rm -fr /tmp/poco-build

#Copy includes
witeMessage "Copying includes..."
mkdir -p $BUILD_ROOT/include
for i in {Foundation,Util,XML,Net,NetSSL_OpenSSL,Crypto,JSON}
do
cp -r $POCO/$i/include/*  $BUILD_ROOT/include
done

doneSection
