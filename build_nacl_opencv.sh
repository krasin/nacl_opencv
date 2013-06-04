set -ue

echo "Installing prerequisite packages"
sudo apt-get install gcc-multilib

echo -n "Creating directory structure... "

BASE=`pwd`

ROOT=`mktemp -d --tmpdir=/tmp`
echo $ROOT

cd $ROOT
echo "Done."

echo -n "Downloading nacl sdk and patching libnacl.a... "
wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip 
unzip nacl_sdk.zip
pushd nacl_sdk
./naclsdk update
cp $BASE/libnacl.a pepper_27/toolchain/linux_x86_newlib/x86_64-nacl/lib/libnacl.a 
popd
echo "Done."

echo -n "Checking out OpenCV sources... "
git clone https://github.com/Itseez/opencv.git
echo "Done."

echo -n "Patching OpenCV sources... "
cd opencv
patch -p1 < $BASE/nacl_opencv.pach
echo "Done."

echo "Building OpenCV with NaCl"
export PATH=$ROOT/nacl_sdk/pepper_27/toolchain/linux_x86_newlib/x86_64-nacl/bin:$PATH
gcc --version

mkdir nacl
cd nacl
cmake -L -DBUILD_SHARED_LIBS=OFF -DWITH_FFMPEG=OFF -DWITH_OPENEXR=OFF -DCUDA_FOUND=0 -DWITH_JASPER=OFF -DBUILD_opencv_apps=OFF ..
make

