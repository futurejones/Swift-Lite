// Flash LED Basic for Swift 4
// A Swift-Lite project file
// type:project
// name:flashLEDBasic

import Glibc
import GPIO

// auto detect board type
let gpios = autoDetectBoardType()

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


