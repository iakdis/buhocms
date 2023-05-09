# Build Linux bundle
cd ..
flutter build linux
cd installers

# Build AppImage
cd AppImage
./build-appimage.sh
./remove-old-appimage.sh
cd ..

# Build Debian
cd Debian
./build-debian.sh
./remove-old-debian.sh
cd ..

# Package Linux portable
./build-linux-portable.sh
