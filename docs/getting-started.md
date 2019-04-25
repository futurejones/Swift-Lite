# Welcome to the Getting Started Guide
## Prerequisites
* Raspberry Pi
* Internet connection
* Latest Raspbian Stretch installed  
*For details on how to setup your Raspberry Pi please go to [raspberrypi.org](raspberrypi.org)*

## Installation
* Update Raspbian  
`sudo apt-get update`
* Add Swift-Lite repository  
`curl -s https://packagecloud.io/install/repositories/swift-arm/swift-lite/script.deb.sh | sudo bash`
* Install Swift-Lite Raspberry Pi Edition  
`sudo apt-get install swift-lite-rpi`
* Test swift install
```
swift --version
Swift version 5.0.* (swift-5.0-RELEASE)
```
* Test swift-lite-build install
```
swift-lite-build --version
swift-lite-build 3.0.*
```

## Setup Project and Modules Directories
* Create the Projects directory  
`mkdir swiftProjects`
* Create the Modules directory  
`mkdir swiftModules`

## A Quick Hello World
* Open the swiftModules directory  
`cd swiftModules`
* Create a file called "print.swift" and open it your favorite text editor.  
`nano print.swift`
* Add a simple function and save the file  
```
func hello() {
    print("Hello World")
}
```
* Open the swiftProject directory  
`cd swiftProjects`
* Create a file called "helloWorld.swift" and open it your favorite text editor.  
`nano helloWorld.swift`
* Add the following code and save the file  
```
// include:print.swift  
hello()
```
* The first line adds `print.swift` as a dependency and the second calls the `hello()` function from the `print.swift` module.
* Next build the project using the --test flag  
`swift-lite-build helloWorld.swift --test`  
You should see the following result  
````
| Processing helloWorld.swift...
|
| Scanning project for modules and libraries
|  - Adding module - print.swift
|
| Generating build command
| Starting Build Process
| Build Finished
| run ./helloWorld.swapp to execute app
|
| <=-------------------------=>
|           Testing           
|
| Hello World
````  
*You are now set up and ready to code with Swift on your Raspberry Pi!*

---

[back](https://futurejones.github.io/Swift-Lite)
