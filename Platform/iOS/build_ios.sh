#!/bin/sh

#  build_poco_ios.sh
#
#

#===============================================================================
# Functions
#===============================================================================

abort()
{
echo
echo "Aborted: $@"
exit 1
}

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

ENABLE_BYTECODE=${ENABLE_BYTECODE:-true}
POCO_OMIT=${POCO_OMIT:-"CppUnit,CppParser,CodeGeneration,Data,Encoding,JWT,Data/SQLite,MongoDB,PDF,Redis,PageCompiler,Remoting,Data/MySQL,Data/ODBC,Zip"}

PLATFORMS=/Applications/Xcode.app/Contents/Developer/Platforms
IPHONE_SDK_VERSION=$1
POCO=$2
iPhoneARCH7=armv7
iPhoneARCH7s=armv7s
iPhoneARCH64=arm64
SIMULATOR_ARCH=i686
SIMULATOR_ARCH64=x86_64

# Locate ar
IPHONEOS_BINARY_AR=`xcrun --sdk iphoneos -find ar`
IPHONESIM_BINARY_AR=`xcrun --sdk iphonesimulator -find ar`

# Locate ranlib
IPHONEOS_BINARY_RANLIB=`xcrun --sdk iphoneos -find ranlib`
IPHONESIM_BINARY_RANLIB=`xcrun --sdk iphonesimulator -find ranlib`

# Locate libtool
#IPHONEOS_BINARY_RANLIB=`xcrun --sdk iphoneos -find libtool`
#IPHONESIM_BINARY_RANLIB=`xcrun --sdk iphonesimulator -find libtool`

FRAMEWORK_NAME=poco
LIBRARY_NAME=libpoco.a

buildFramework()
{
DEBUG=$1
if [ "$DEBUG" == 'DEBUG' ]; then
echo "Will be building a DEBUG framework..."
DEBUG='d'
elif [ "$DEBUG" == 'RELEASE' ]; then
echo "Will be building a RELEASE framework..."
DEBUG=''
else
echo "You need to choose DEBUG or RELEASE as first param to buildFramework()"
exit 1
fi

CURRENT_DIR=${PWD}
FRAMEWORKDIR=$2/iOS/framework

#PATH_TO_LIBS_i386=$3
PATH_TO_LIBS_x86_64=$3
#PATH_TO_LIBS_ARM7=$5
#PATH_TO_LIBS_ARM7s=$6
PATH_TO_LIBS_ARM64=$4

FRAMEWORK_BUNDLE=$FRAMEWORKDIR/$FRAMEWORK_NAME

rm -rf $FRAMEWORK_BUNDLE

witeMessage "Framework: Creating $FRAMEWORK_NAME framework"

witeMessage "Framework: Setting up directories..."
mkdir -p $FRAMEWORK_BUNDLE
mkdir -p $FRAMEWORK_BUNDLE/include
mkdir -p $FRAMEWORK_BUNDLE/lib

witeMessage "Decomposing each architecture's .a files"
for file in {Foundation$DEBUG,Util$DEBUG,XML$DEBUG,Net$DEBUG,NetSSL$DEBUG,Crypto$DEBUG,JSON$DEBUG}
do
echo "Decomposing $file for iPhoneSimulator..."
#mkdir -p $PATH_TO_LIBS_i386/obj
#mkdir -p $PATH_TO_LIBS_i386/${file}
mkdir -p $PATH_TO_LIBS_x86_64/${file}
#(cd $PATH_TO_LIBS_i386/$file; $IPHONESIM_BINARY_AR -x ../libPoco$file.a );
(cd $PATH_TO_LIBS_x86_64/$file; $IPHONESIM_BINARY_AR -x ../libPoco$file.a );
done

for file in {Foundation$DEBUG,Util$DEBUG,XML$DEBUG,Net$DEBUG,NetSSL$DEBUG,Crypto$DEBUG,JSON$DEBUG}
do
echo "Decomposing $file for iPhoneOS..."
#mkdir -p $PATH_TO_LIBS_ARM7/obj
#mkdir -p $PATH_TO_LIBS_ARM7/${file}
#mkdir -p $PATH_TO_LIBS_ARM7s/${file}
mkdir -p $PATH_TO_LIBS_ARM64/${file}
#(cd $PATH_TO_LIBS_ARM7/$file; $IPHONEOS_BINARY_AR -x ../libPoco$file.a );
#(cd $PATH_TO_LIBS_ARM7s/$file; $IPHONEOS_BINARY_AR -x ../libPoco$file.a );
(cd $PATH_TO_LIBS_ARM64/$file; $IPHONEOS_BINARY_AR -x ../libPoco$file.a );
done
doneSection

witeMessage "Linking each architecture into a libPoco${DEBUG}.a"
echo "Linking objects for iPhoneSimulator..."
#(cd $PATH_TO_LIBS_i386; $IPHONESIM_BINARY_AR crus libPoco${DEBUG}.a Foundation$DEBUG/*.o Util$DEBUG/*.o XML$DEBUG/*.o Net$DEBUG/*.o NetSSL$DEBUG/*.o Crypto$DEBUG/*.o Data$DEBUG/*.o DataSQLite$DEBUG/*.o );
(cd $PATH_TO_LIBS_x86_64; $IPHONESIM_BINARY_AR crus libPoco${DEBUG}.a Foundation$DEBUG/*.o Crypto$DEBUG/*.o Util$DEBUG/*.o XML$DEBUG/*.o Net$DEBUG/*.o NetSSL$DEBUG/*.o JSON$DEBUG/*.o );
echo "Linking objects for iPhoneOS..."
#(cd $PATH_TO_LIBS_ARM7; $IPHONEOS_BINARY_AR crus libPoco${DEBUG}.a Foundation$DEBUG/*.o Crypto$DEBUG/*.o Util$DEBUG/*.o XML$DEBUG/*.o Net$DEBUG/*.o NetSSL$DEBUG/*.o JSON$DEBUG/*.o );
#(cd $PATH_TO_LIBS_ARM7s; $IPHONEOS_BINARY_AR crus libPoco${DEBUG}.a Foundation$DEBUG/*.o Crypto$DEBUG/*.o Util$DEBUG/*.o XML$DEBUG/*.o Net$DEBUG/*.o NetSSL$DEBUG/*.o JSON$DEBUG/*.o );
(cd $PATH_TO_LIBS_ARM64; $IPHONEOS_BINARY_AR crus libPoco${DEBUG}.a Foundation$DEBUG/*.o Crypto$DEBUG/*.o Util$DEBUG/*.o XML$DEBUG/*.o Net$DEBUG/*.o NetSSL$DEBUG/*.o JSON$DEBUG/*.o );
doneSection

for file in {Foundation$DEBUG,Util$DEBUG,XML$DEBUG,Net$DEBUG,NetSSL$DEBUG,Crypto$DEBUG,JSON$DEBUG}
do
echo "Cleaning $file..."
#rm -rf $PATH_TO_LIBS_i386/${file}
rm -rf $PATH_TO_LIBS_x86_64/${file}
#rm -rf $PATH_TO_LIBS_ARM7/${file}
#rm -rf $PATH_TO_LIBS_ARM7s/${file}
rm -rf $PATH_TO_LIBS_ARM64/${file}
done

cd $CURRENT_DIR

LIBRARY_INSTALL_NAME=$FRAMEWORK_BUNDLE/lib/$LIBRARY_NAME

xcrun -sdk iphoneos lipo \
-create \
-arch x86_64 "$PATH_TO_LIBS_x86_64/libPoco${DEBUG}.a" \
-arch arm64 "$PATH_TO_LIBS_ARM64/libPoco${DEBUG}.a" \
-o "$LIBRARY_INSTALL_NAME" \
|| abort "Lipo $1 failed"

$IPHONEOS_BINARY_RANLIB "$LIBRARY_INSTALL_NAME"


witeMessage "Framework: Copying includes..."
for i in {Foundation,Util,XML,Net,NetSSL_OpenSSL,Crypto,JSON}
do
cp -r $POCO/$i/include/*  $FRAMEWORK_BUNDLE/include
done

doneSection
}


#Execution starts here
cd $POCO

$ENABLE_BYTECODE && export CXXFLAGS2="-fembed-bitcode"

./configure \
--include-path=/usr/local/opt/openssl@1.1/include \
--config=iPhoneSimulator-clang-libc++ \
--static \
--no-tests \
--no-samples \
--omit=$POCO_OMIT

#make -j32 POCO_TARGET_OSARCH=i686 IPHONE_SDK_VERSION_MIN="$IPHONE_SDK_VERSION" POCO_FLAGS="$CXXFLAGS2"
make -j32 POCO_TARGET_OSARCH=x86_64 IPHONE_SDK_VERSION_MIN="$IPHONE_SDK_VERSION" POCO_FLAGS="$CXXFLAGS2"

./configure \
--include-path=/usr/local/opt/openssl@1.1/include \
--config=iPhone-clang-libc++ \
--static \
--no-tests \
--no-samples \
--omit=$POCO_OMIT

#make -j32 POCO_TARGET_OSARCH=armv7 IPHONE_SDK_VERSION_MIN="$IPHONE_SDK_VERSION" POCO_FLAGS="$CXXFLAGS2"
#make -j32 POCO_TARGET_OSARCH=armv7s IPHONE_SDK_VERSION_MIN="$IPHONE_SDK_VERSION" POCO_FLAGS="$CXXFLAGS2"
make -j32 POCO_TARGET_OSARCH=arm64 IPHONE_SDK_VERSION_MIN="$IPHONE_SDK_VERSION" POCO_FLAGS="$CXXFLAGS2"

buildFramework 'RELEASE' ${PWD}/lib `pwd`/lib/iPhoneSimulator/$SIMULATOR_ARCH64 `pwd`/lib/iPhoneOS/$iPhoneARCH64
