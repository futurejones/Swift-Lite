// Flash LED Basic for Swift 4
// A Swift-Lite project file
// type:project
// name:flashLEDBasic
// include:swift4GPIO.swift

import Glibc

// auto detect board type (detects all boards with 40 GPIO pins)
let gpios = autoDetectBoardType()

// for older boards with 26 GPIO pins please set board type manually
//let gpios = PiCodeGPIO.RPIRev1
//let gpios = PiCodeGPIO.RPIRev2

// set output pin
var gp = gpios[.P17]!
gp.direction = .OUT
gp.value = 1

var flashNumber = 10

repeat{
       print("flash on")
       usleep(500*1000)
       gp.value = 1

       print("flash off")
       usleep(500*1000)
       gp.value = 0

     flashNumber -= 1

} while(flashNumber > 0)


