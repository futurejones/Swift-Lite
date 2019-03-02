# Swift-Lite Samples and Tests
<a href="https://github.com/futurejones/Swift-Lite-Samples/blob/master/LICENSE.md"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>

## Swift 4
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift%204-compatible-orange.svg" /></a>&nbsp;&nbsp;<a href="https://raspberrypi.org"><img src="https://img.shields.io/badge/Raspberry%20Pi-2%20and%203-green.svg" /></a>&nbsp;&nbsp;<a href="https://www.raspberrypi.org/downloads/raspbian/"><img src="https://img.shields.io/badge/Raspbian-Stretch-green.svg" /></a>&nbsp;&nbsp;

### Sample Project and Module files for Swift-Lite
#### Projects
* Helloworld
* Flash LED Basic
* Flash LED using Timers
* HC-SR04 Ultrasonics Distance Measurement

#### Modules
* Date - Returns the current date in full style
* Time - Uses DispatchTime to insert wait time - Usage similar to usleep/sleep
* Command - Run terminal shell commands

#### Libraries
* GPIO - Access and control the GPIO pins - Features auto board type detect for all Raspberry Pi's

### What is Swift-Lite?
Swift-Lite is a super lean version of Swift built for small arm SBC's like the Raspberry Pi, BeagleBone and the CHIP running Debian based Linux OS. This includes Raspbian, Ubuntu, Debian and others. Swift-Lite uses meta-tags combined with the pre-build processor to make constructing a multi-file Swift project with Module dependancies easy and simple. Swift Modules can be used in much the same way you would use a Framework or a Library.

Swift-Lite is built from the official repo on Swift.org. It includes Foundation, Dispatch and all the main core features of Swift. What it doesn't include are the Swift add-ons such as Package Manager, REPL, LLDB and XCTest.

### What is swift-lite-build
<img src="https://img.shields.io/badge/Swift%20Lite%20Build-Linux-green.svg" />

swift-lite-build is a simple bash script that first, scans the swift project file for module dependencies, and then creates a custom swiftc build command to build the project. swift-lite-build is able to do this by scanning the included meta tags in the swift project and module files.

#### The Project File
To use a project file with swift-lite-build add the following meta tags.

``` 
// name:helloworld
// type:project
// include:numbers.swift
// include:date.swift
```

#### The Module File
To use a module file with swift-lite-build add the following meta tags.

``` 
// name:numbers
// type:module
```

#### File Location
 - Project files can be located in any directory located in the "/home/user/" directory.
 - Module files must be located in a directory named "swiftModules". "swiftModules" can be located in any directory located in the "/home/user/" directory. 
 
NOTE: There must only be one "swiftModules" directory.


