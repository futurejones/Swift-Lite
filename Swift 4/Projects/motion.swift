// Motion for Swift 4
// A Swift-Lite project file
// type:project
// name:motion
// include:time.swift

import Glibc
import GPIO

// auto detect board type
let gpios = autoDetectBoardType()

// set output pin for LED
var gp_led = gpios[.P17]!
gp_led.direction = .OUT
gp_led.value = 0

// set input pin for Motion Sensor
var gp_ms = gpios[.P21]!
gp_ms.direction = .IN
//gp_ms.value = 0
print(gp_ms.value)
while true {
    repeat {
        gp_led.value = 0
    } while (gp_ms.value == 0)

    gp_led.value = 1
    print("motion detected")
    wait(time: 2)
    gp_led.value = 0
}

