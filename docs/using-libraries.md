# Creating, Importing and Using Swift Libraries in Swift-Lite
## How to Create a Swift-Lite-Library-Sample

## Build Instructions
* Clone the `Swift-Lite-Library-Sample` repo  
`git clone https://github.com/futurejones/Swift-Lite-Library-Sample.git`
* Open the `Sample_Library` directory  
`cd Swift-Lite-Library-Sample/Sample_Library`
* Add any required source files to the `Source` directory
* Build the library (*NOTE: Change "MyLibrary" to the name of your library*)  
`swiftc -emit-library -emit-module -parse-as-library -module-name MyLibrary Source/*.swift`
* Copy the `lib.so`, `.swiftdoc` and `.swiftmodule` files to `myLibrary/usr/lib/` directory  
`cp libMyLibrary.so MyLibrary.swiftdoc MyLibrary.swiftmodule myLibrary/usr/lib/`
* Rename `myLibrary` directory to the name you want your `.deb` package to be called.(*NOTE: This can be different to your library name*)
* Edit the `DEBIAN/control` file as required.
* Build the `.deb` package (*NOTE: Change "myLibrary" to the name of your library directory*)  
`dpkg-deb --build myLibrary`

## Install Instructions
* `sudo dpkg -i myLibrary.deb` or `sudo dpkg --install myLibrary.deb`

## Usage Instruction
* add `import MyLibrary` to your project file.

## Uninstall / Remove
* `dpkg -r myLibrary` or `dpkg --remove myLibrary`

---

[back](https://futurejones.github.io/Swift-Lite)
