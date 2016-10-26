// PiCode GPIO for Swift 3.0
// A Swift-Lite module file
// type:module
// name:PiCodeGPIO
//


import Foundation
import Glibc

// start - Auto detect board type

func shell(command: String) {
    let task = Task()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()
}

func autoDetectBoardType() -> [GPIOName:GPIO]{
    // set default board type to Pi2/3
    var boardType = PiCodeGPIO.RPI2
    shell(command: "cp -f /proc/cpuinfo /tmp/cpu.txt")
    let path = "/tmp/cpu.txt"
    var fileContents:String = ""
    let filemgr = FileManager.default
    
    if filemgr.fileExists(atPath: path) {
        fileContents = try! String(contentsOfFile: path, encoding: String.Encoding.ascii)
        
        if fileContents.contains("BCM2709") {
            boardType = PiCodeGPIO.RPI2
            return boardType
        } else if fileContents.contains("BCM2708") {
            boardType = PiCodeGPIO.RPIPlusZERO
            return boardType
        } else {
            // return default
            return boardType
        }
 
    } else {
        // return default
        return boardType
    }
   
}

// end


internal let GPIOBASEPATH="/sys/class/gpio/"
internal let SPIBASEPATH="/dev/spidev"

public enum GPIODirection:String {
    case IN="in"
    case OUT="out"
}

public enum GPIOEdge:String {
    case NONE="none"
    case RISING="rising"
    case FALLING="falling"
    case BOTH="both"
}

public enum ByteOrder{
    case MSBFIRST
    case LSBFIRST
}


public class GPIO {
    var name:String=""
    var id:Int=0
    var exported=false
    var listening = false
    var intThread:Thread? = nil
    var intFuncFalling:((GPIO)->Void)? = nil
    var intFuncRaising:((GPIO)->Void)? = nil
    var intFuncChange:((GPIO)->Void)? = nil


    init(name:String,
        id:Int) {
        self.name=name
        self.id=id
    }

    public var direction:GPIODirection {
        set(dir){
            if !exported {enableIO(id:id)}
            performSetting(filename:"gpio"+String(id)+"/direction",value: dir.rawValue)
        }
        get {
            if !exported {enableIO(id:id)}
            return GPIODirection(rawValue: getStringValue(filename:"gpio"+String(id)+"/direction")!)!
        }
    }

    public var edge:GPIOEdge {
        set(dir){
            if !exported {enableIO(id:id)}
            performSetting(filename:"gpio"+String(id)+"/edge",value: dir.rawValue)
        }
        get {
            if !exported {enableIO(id:id)}
            return GPIOEdge(rawValue: getStringValue(filename:"gpio"+String(id)+"/edge")!)!
        }
    }

    public var activeLow:Bool{
        set(act){
            if !exported {enableIO(id:id)}
            performSetting(filename:"gpio"+String(id)+"/active_low",value: act ? "1":"0")
        }
        get {
            if !exported {enableIO(id:id)}
            return getIntValue(filename:"gpio"+String(id)+"/active_low")==0
        }
    }

    public var value:Int{
        set(val){
            if !exported {enableIO(id:id)}
            performSetting(filename:"gpio"+String(id)+"/value",value: val)
        }
        get {
            if !exported {enableIO(id:id)}
            return getIntValue(filename:"gpio"+String(id)+"/value")!
        }
    }

    public func isMemoryMapped()->Bool{
        return false
    }

    func onFalling(closure:@escaping (GPIO)->Void){
        intFuncFalling = closure
        if intThread == nil {
            intThread = newInterruptThread()
            listening = true
        }
    }

    func onRaising(closure:@escaping (GPIO)->Void){
        intFuncRaising = closure
        if intThread == nil {
            intThread = newInterruptThread()
            listening = true
        }
    }

    func onChange(closure:@escaping (GPIO)->Void){
        intFuncChange = closure
        if intThread == nil {
            intThread = newInterruptThread()
            listening = true
        }
    }

    func clearListeners(){
        (intFuncFalling,intFuncRaising,intFuncChange) = (nil,nil,nil)
        listening = false
    }

}

extension GPIO {

    func enableIO(id: Int){
        writeToFile(path:GPIOBASEPATH+"export",value:String(id))
        exported = true
    }

    func performSetting(filename: String, value: String){
        writeToFile(path:GPIOBASEPATH+filename, value:value)
    }

    func performSetting(filename: String, value: Int){
        writeToFile(path:GPIOBASEPATH+filename, value: String(value))
    }

    func getStringValue(filename: String)->String?{
        return readFromFile(path:GPIOBASEPATH+filename)
    }

    func getIntValue(filename: String)->Int?{
        if let res = readFromFile(path:GPIOBASEPATH+filename) {
            return Int(res)
        }
        return nil
    }

    private func writeToFile(path: String, value:String){
        let fp = fopen(path,"w")
        if fp != nil {
            let ret = fwrite(value, MemoryLayout<CChar>.stride, value.characters.count, fp)
            if ret<value.characters.count {
                if ferror(fp) != 0 {
                    perror("Error while writing to file")
                    abort()
                }
            }
            fclose(fp)
        }
    }

    private func readFromFile(path:String)->String?{
        let MAXLEN = 8

        let fp = fopen(path,"r")
        var res:String?
        if fp != nil {
            let buf = UnsafeMutablePointer<CChar>.allocate(capacity: MAXLEN)
            let len = fread(buf, MemoryLayout<CChar>.stride, MAXLEN, fp)
            if len < MAXLEN {
                if ferror(fp) != 0 {
                    perror("Error while reading from file")
                    abort()
                }
            }
            fclose(fp)
            buf[len-1]=0
            res = String(cString: buf)
            buf.deallocate(capacity: MAXLEN)
        }
        return res
    }

    func newInterruptThread() -> Thread{
        let thread = Thread(){

            let gpath = GPIOBASEPATH+"gpio"+String(self.id)+"/value"
            self.direction = .IN
            self.edge = .BOTH

            let fp = open(gpath,O_RDONLY)
            var buf:[Int8] = [0,0,0]
            read(fp,&buf,3)

            var pfd = pollfd(fd:fp,events:Int16(truncatingBitPattern:POLLPRI),revents:0)

            while self.listening {
                let ready = poll(&pfd, 1, -1)
                if ready > -1 {
                    lseek(fp, 0, SEEK_SET)
                    read(fp,&buf,2)
                    buf[1]=0

                    let res = String(cString: buf)
                    switch(res){
                    case "0":
                        self.intFuncFalling?(self)
                    case "1":
                        self.intFuncRaising?(self)
                    default:
                        break
                    }
                    self.intFuncChange?(self)
                }
            }
        }
        thread.start()
        return thread
    }
}

public class RaspiGPIO : GPIO {
    var setGetId=0
    var baseAddr:Int=0
    var inited=false

    let BCM2708_PERI_BASE:Int
    let GPIO_BASE:Int
    let PAGE_SIZE = 4*1024
    let BLOCK_SIZE = 4*1024

    var gpioBasePointer:UnsafeMutablePointer<Int>?
    var gpioGetPointer:UnsafeMutablePointer<Int>?
    var gpioSetPointer:UnsafeMutablePointer<Int>?
    var gpioClearPointer:UnsafeMutablePointer<Int>?


    init(name:String, id:Int, baseAddr:Int) {
        self.setGetId = 1<<id
        self.BCM2708_PERI_BASE = baseAddr
        self.GPIO_BASE = BCM2708_PERI_BASE + 0x200000
        super.init(name:name,id:id)
        
    }

    public override var value:Int{
        set(val){
            if !inited {initIO(id:id)}
            gpioSet(value:val)
        }
        get {
            if !inited {initIO(id:id)}
            return gpioGet()
        }
    }

    public override func isMemoryMapped()->Bool{
        return true
    }

    private func initIO(id: Int){
        let mem_fd = open("/dev/mem", O_RDWR|O_FSYNC)
        guard (mem_fd > 0) else {
            print("Can't open /dev/mem")
            abort()
        }

        let gpio_map = mmap(
            nil,
            BLOCK_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            mem_fd,
            off_t(GPIO_BASE)
            )

        close(mem_fd)

        let gpioBasePointer = gpio_map?.assumingMemoryBound(to: Int.self)
        if (gpioBasePointer?.pointee == -1) {
            print("mmap error: " + String(describing: gpioBasePointer))
            abort()
        }
        
        gpioGetPointer = (gpioBasePointer?.advanced(by:13))!
        gpioSetPointer = (gpioBasePointer?.advanced(by:7))!
        gpioClearPointer = (gpioBasePointer?.advanced(by:10))!

        inited = true
    }
 
    private func gpioAsInput(){
        let ptr = gpioBasePointer?.advanced(by:id/10)
        ptr?.pointee &= ~(7<<((id%10)*3))
    }

    private func gpioAsOutput(){
        let ptr = gpioBasePointer?.advanced(by:id/10)
        ptr?.pointee &= ~(7<<((id%10)*3))
        ptr?.pointee |=  (1<<((id%10)*3))
    }  
    
    private func gpioGet()->Int{
        return ((gpioGetPointer!.pointee & setGetId)>0) ? 1 : 0
    }

    private func gpioSet(value:Int){
        let ptr = value==1 ? gpioSetPointer : gpioClearPointer
        ptr?.pointee = setGetId
    }
 
}
 

public protocol SPIOutput{                     
    func sendData(values:[UInt8], order:ByteOrder, clockDelayUsec:Int)
    func sendData(values:[UInt8])
    func isHardware()->Bool
    func isOut()->Bool
}

public struct HardwareSPI : SPIOutput{
    let spiId:String
    let isOutput:Bool

    init(spiId:String,isOutput:Bool){
        self.spiId=spiId
        self.isOutput=isOutput
        
    }

    public func sendData(values:[UInt8], order:ByteOrder, clockDelayUsec:Int){
        guard isOutput else {return}

        if clockDelayUsec > 0 {
            
        }
        
        writeToFile(path:SPIBASEPATH+spiId, values:values)
    }

    public func sendData(values:[UInt8]){sendData(values:values,order:.MSBFIRST,clockDelayUsec:0)}

    public func isHardware()->Bool{
        return true
    } 

    public func isOut()->Bool{
        return isOutput
    }
 
    private func writeToFile(path: String, values:[UInt8]){
        let fp = fopen(path,"w")
        if fp != nil {
            let ret = fwrite(values, MemoryLayout<CChar>.stride, values.count, fp)
            if ret<values.count {
                if ferror(fp) != 0 {
                    perror("Error while writing to file")
                    abort()
                }
            }
            fclose(fp)
        }
    }
 
}


public struct VirtualSPI : SPIOutput{
    let dataGPIO,clockGPIO:GPIO

    init(dataGPIO:GPIO,clockGPIO:GPIO){
        self.dataGPIO = dataGPIO
        self.dataGPIO.direction = .OUT
        self.dataGPIO.value = 0
        self.clockGPIO = clockGPIO
        self.clockGPIO.direction = .OUT
        self.clockGPIO.value = 0
    }


    public func sendData(values:[UInt8], order:ByteOrder, clockDelayUsec:Int){
        let mmapped = dataGPIO.isMemoryMapped()
        if mmapped {
            sendDataGPIOObj(values:values, order:order, clockDelayUsec:clockDelayUsec)
        }else{
            sendDataSysFS(values:values, order:order, clockDelayUsec:clockDelayUsec)
        }
    }

    public func sendDataGPIOObj(values:[UInt8], order:ByteOrder, clockDelayUsec:Int){

        var bit:Int = 0
        for value in values {
            for i in 0...7 {
                switch order {
                    case .LSBFIRST:
                        bit = ((value & UInt8(1 << i)) == 0) ? 0 : 1
                    case .MSBFIRST:
                        bit = ((value & UInt8(1 << (7-i))) == 0) ? 0 : 1
                }
            
                dataGPIO.value = bit
                clockGPIO.value = 1
                if clockDelayUsec>0 {
                    usleep(UInt32(clockDelayUsec))
                }
                clockGPIO.value = 0
            }
        }
    }
 
    public func sendDataSysFS(values:[UInt8], order:ByteOrder, clockDelayUsec:Int){

        let mosipath = GPIOBASEPATH+"gpio"+String(self.dataGPIO.id)+"/value"
        let sclkpath = GPIOBASEPATH+"gpio"+String(self.clockGPIO.id)+"/value"
        let HIGH = "1"
        let LOW = "0"

        let fpmosi = fopen(mosipath,"w")
        let fpsclk = fopen(sclkpath,"w")

        guard (fpmosi != nil)&&(fpsclk != nil) else {
            perror("Error while opening gpio")
            abort()
        }
        setvbuf(fpmosi, nil, _IONBF, 0)
        setvbuf(fpsclk, nil, _IONBF, 0)

        var bit:String = LOW
        for value in values {        
            for i in 0...7 {
                switch order {
                    case .LSBFIRST:
                        bit = ((value & UInt8(1 << i)) == 0) ? LOW : HIGH
                    case .MSBFIRST:
                        bit = ((value & UInt8(1 << (7-i))) == 0) ? LOW : HIGH
                }
            
                writeToFP(fp:fpmosi!,value:bit)
                writeToFP(fp:fpsclk!,value:HIGH)
                if clockDelayUsec>0 {
                    usleep(UInt32(clockDelayUsec))
                }
                writeToFP(fp:fpsclk!,value:LOW)
            }
        }
        fclose(fpmosi)
        fclose(fpsclk)
    }

    private func writeToFP(fp: UnsafeMutablePointer<FILE>, value:String){
       let ret = fwrite(value, MemoryLayout<CChar>.stride, 1, fp)
       if ret<1 {
           if ferror(fp) != 0 {
               perror("Error while writing to file")
               abort()
           }
       }
    }
 
    public func sendData(values:[UInt8]){
        self.sendData(values:values,order:.MSBFIRST,clockDelayUsec:0)
    }

    public func isHardware()->Bool{
        return false
    }

    public func isOut()->Bool{
        return true
    }
}


public struct PiCodeGPIO {
    // RaspberryPi A and B Revision 1 (Before September 2012) - 26 pin header boards
    
    static let RPIRev1:[GPIOName:GPIO] = [
        .P0:RaspiGPIO(name:"GPIO0",id:0,baseAddr:0x20000000),
        .P1:RaspiGPIO(name:"GPIO1",id:1,baseAddr:0x20000000),
        .P4:RaspiGPIO(name:"GPIO4",id:4,baseAddr:0x20000000),
        .P7:RaspiGPIO(name:"GPIO7",id:7,baseAddr:0x20000000),
        .P8:RaspiGPIO(name:"GPIO8",id:8,baseAddr:0x20000000),
        .P9:RaspiGPIO(name:"GPIO9",id:9,baseAddr:0x20000000),
        .P10:RaspiGPIO(name:"GPIO10",id:10,baseAddr:0x20000000),
        .P11:RaspiGPIO(name:"GPIO11",id:11,baseAddr:0x20000000),
        .P14:RaspiGPIO(name:"GPIO14",id:14,baseAddr:0x20000000),
        .P15:RaspiGPIO(name:"GPIO15",id:15,baseAddr:0x20000000),
        .P17:RaspiGPIO(name:"GPIO17",id:17,baseAddr:0x20000000),
        .P18:RaspiGPIO(name:"GPIO18",id:18,baseAddr:0x20000000),
        .P21:RaspiGPIO(name:"GPIO21",id:21,baseAddr:0x20000000),
        .P22:RaspiGPIO(name:"GPIO22",id:22,baseAddr:0x20000000),
        .P23:RaspiGPIO(name:"GPIO23",id:23,baseAddr:0x20000000),
        .P24:RaspiGPIO(name:"GPIO24",id:24,baseAddr:0x20000000),
        .P25:RaspiGPIO(name:"GPIO25",id:25,baseAddr:0x20000000)
    ]

    // RaspberryPi A and B Revision 2 (After September 2012) - 26 pin header boards
   
    static let RPIRev2:[GPIOName:GPIO] = [
        .P2:RaspiGPIO(name:"GPIO2",id:2,baseAddr:0x20000000),
        .P3:RaspiGPIO(name:"GPIO3",id:3,baseAddr:0x20000000),
        .P4:RaspiGPIO(name:"GPIO4",id:4,baseAddr:0x20000000),
        .P7:RaspiGPIO(name:"GPIO7",id:7,baseAddr:0x20000000),
        .P8:RaspiGPIO(name:"GPIO8",id:8,baseAddr:0x20000000),
        .P9:RaspiGPIO(name:"GPIO9",id:9,baseAddr:0x20000000),
        .P10:RaspiGPIO(name:"GPIO10",id:10,baseAddr:0x20000000),
        .P11:RaspiGPIO(name:"GPIO11",id:11,baseAddr:0x20000000),
        .P14:RaspiGPIO(name:"GPIO14",id:14,baseAddr:0x20000000),
        .P15:RaspiGPIO(name:"GPIO15",id:15,baseAddr:0x20000000),
        .P17:RaspiGPIO(name:"GPIO17",id:17,baseAddr:0x20000000),
        .P18:RaspiGPIO(name:"GPIO18",id:18,baseAddr:0x20000000),
        .P22:RaspiGPIO(name:"GPIO22",id:22,baseAddr:0x20000000),
        .P23:RaspiGPIO(name:"GPIO23",id:23,baseAddr:0x20000000),
        .P24:RaspiGPIO(name:"GPIO24",id:24,baseAddr:0x20000000),
        .P25:RaspiGPIO(name:"GPIO25",id:25,baseAddr:0x20000000),
        .P27:RaspiGPIO(name:"GPIO27",id:27,baseAddr:0x20000000)
    ]

    // RaspberryPi A+ and B+, Raspberry Zero - 40 pin header boards
    
    static let RPIPlusZERO:[GPIOName:GPIO] = [
        .P2:RaspiGPIO(name:"GPIO2",id:2,baseAddr:0x20000000),
        .P3:RaspiGPIO(name:"GPIO3",id:3,baseAddr:0x20000000),
        .P4:RaspiGPIO(name:"GPIO4",id:4,baseAddr:0x20000000),
        .P5:RaspiGPIO(name:"GPIO5",id:5,baseAddr:0x20000000),
        .P6:RaspiGPIO(name:"GPIO6",id:6,baseAddr:0x20000000),
        .P7:RaspiGPIO(name:"GPIO7",id:7,baseAddr:0x20000000),
        .P8:RaspiGPIO(name:"GPIO8",id:8,baseAddr:0x20000000),
        .P9:RaspiGPIO(name:"GPIO9",id:9,baseAddr:0x20000000),
        .P10:RaspiGPIO(name:"GPIO10",id:10,baseAddr:0x20000000),
        .P11:RaspiGPIO(name:"GPIO11",id:11,baseAddr:0x20000000),
        .P12:RaspiGPIO(name:"GPIO12",id:12,baseAddr:0x20000000),
        .P13:RaspiGPIO(name:"GPIO13",id:13,baseAddr:0x20000000),
        .P14:RaspiGPIO(name:"GPIO14",id:14,baseAddr:0x20000000),
        .P15:RaspiGPIO(name:"GPIO15",id:15,baseAddr:0x20000000),
        .P16:RaspiGPIO(name:"GPIO16",id:16,baseAddr:0x20000000),
        .P17:RaspiGPIO(name:"GPIO17",id:17,baseAddr:0x20000000),
        .P18:RaspiGPIO(name:"GPIO18",id:18,baseAddr:0x20000000),
        .P19:RaspiGPIO(name:"GPIO19",id:19,baseAddr:0x20000000),
        .P20:RaspiGPIO(name:"GPIO20",id:20,baseAddr:0x20000000),
        .P21:RaspiGPIO(name:"GPIO21",id:21,baseAddr:0x20000000),
        .P22:RaspiGPIO(name:"GPIO22",id:22,baseAddr:0x20000000),
        .P23:RaspiGPIO(name:"GPIO23",id:23,baseAddr:0x20000000),
        .P24:RaspiGPIO(name:"GPIO24",id:24,baseAddr:0x20000000),
        .P25:RaspiGPIO(name:"GPIO25",id:25,baseAddr:0x20000000),
        .P26:RaspiGPIO(name:"GPIO26",id:26,baseAddr:0x20000000),
        .P27:RaspiGPIO(name:"GPIO27",id:27,baseAddr:0x20000000)
    ]
 
    // RaspberryPi 2
    
    static let RPI2:[GPIOName:GPIO] = [
        .P2:RaspiGPIO(name:"GPIO2",id:2,baseAddr:0x3F000000),
        .P3:RaspiGPIO(name:"GPIO3",id:3,baseAddr:0x3F000000),
        .P4:RaspiGPIO(name:"GPIO4",id:4,baseAddr:0x3F000000),
        .P5:RaspiGPIO(name:"GPIO5",id:5,baseAddr:0x3F000000),
        .P6:RaspiGPIO(name:"GPIO6",id:6,baseAddr:0x3F000000),
        .P7:RaspiGPIO(name:"GPIO7",id:7,baseAddr:0x3F000000),
        .P8:RaspiGPIO(name:"GPIO8",id:8,baseAddr:0x3F000000),
        .P9:RaspiGPIO(name:"GPIO9",id:9,baseAddr:0x3F000000),
        .P10:RaspiGPIO(name:"GPIO10",id:10,baseAddr:0x3F000000),
        .P11:RaspiGPIO(name:"GPIO11",id:11,baseAddr:0x3F000000),
        .P12:RaspiGPIO(name:"GPIO12",id:12,baseAddr:0x3F000000),
        .P13:RaspiGPIO(name:"GPIO13",id:13,baseAddr:0x3F000000),
        .P14:RaspiGPIO(name:"GPIO14",id:14,baseAddr:0x3F000000),
        .P15:RaspiGPIO(name:"GPIO15",id:15,baseAddr:0x3F000000),
        .P16:RaspiGPIO(name:"GPIO16",id:16,baseAddr:0x3F000000),
        .P17:RaspiGPIO(name:"GPIO17",id:17,baseAddr:0x3F000000),
        .P18:RaspiGPIO(name:"GPIO18",id:18,baseAddr:0x3F000000),
        .P19:RaspiGPIO(name:"GPIO19",id:19,baseAddr:0x3F000000),
        .P20:RaspiGPIO(name:"GPIO20",id:20,baseAddr:0x3F000000),
        .P21:RaspiGPIO(name:"GPIO21",id:21,baseAddr:0x3F000000),
        .P22:RaspiGPIO(name:"GPIO22",id:22,baseAddr:0x3F000000),
        .P23:RaspiGPIO(name:"GPIO23",id:23,baseAddr:0x3F000000),
        .P24:RaspiGPIO(name:"GPIO24",id:24,baseAddr:0x3F000000),
        .P25:RaspiGPIO(name:"GPIO25",id:25,baseAddr:0x3F000000),
        .P26:RaspiGPIO(name:"GPIO26",id:26,baseAddr:0x3F000000),
        .P27:RaspiGPIO(name:"GPIO27",id:27,baseAddr:0x3F000000)
    ]
 
    static let SPIRPI:[Int:SPIOutput] = [
        0:HardwareSPI(spiId:"0.0",isOutput:true),
        1:HardwareSPI(spiId:"0.1",isOutput:false)
    ]

}

public enum GPIOName {
    case P0
    case P1
    case P2
    case P3
    case P4
    case P5
    case P6
    case P7
    case P8
    case P9
    case P10
    case P11
    case P12
    case P13
    case P14
    case P15
    case P16
    case P17
    case P18
    case P19
    case P20
    case P21
    case P22
    case P23
    case P24
    case P25
    case P26
    case P27
    
}
