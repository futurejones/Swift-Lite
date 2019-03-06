## The Swift-Lite GPIO Library

---

*The Swift-Lite GPIO library is based on `SwiftyGPIO`, the great work by Umberto Raimondi*  
*More info at https://github.com/uraimo/SwiftyGPIO*

---

### Usage
First, we need import GPIO and then retrieve the list of GPIOs available on the board and get a reference to the one we want to modify.  
GPIO will autodetect your board type.

<code>
import GPIO
</br>
autoDetectBoardType()
</code>

---

[back](https://futurejones.github.io/Swift-Lite)