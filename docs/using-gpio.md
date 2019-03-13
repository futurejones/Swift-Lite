## The Swift-Lite GPIO Library

---

*The Swift-Lite GPIO library is based on `SwiftyGPIO`, the great work by Umberto Raimondi*  
*More info at https://github.com/uraimo/SwiftyGPIO*

---

### Usage
First, we need import GPIO and then retrieve the list of GPIOs available on the board. The GPIO library will autodetect your board type using the `autoDetectBoardType()` function.

````
import GPIO

autoDetectBoardType()
````
Next we need to get a reference to the pin we want to control and set the initial parameters.  
This can be either `gp.direction = .IN` or `gp.direction = .OUT`
````
// set pin number
var gp = gpios[.P9]!

// set pin direction
gp.direction = .OUT
````
We can control the pin by setting the pin value. 1 = on, 0 = off.
````
// set pin value
gp.value = 0
````

For more advanced usage please see [SwiftyGPIO Usage](https://github.com/uraimo/SwiftyGPIO#usage)

---

[back](https://futurejones.github.io/Swift-Lite)
