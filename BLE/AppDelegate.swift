import Cocoa
import CoreBluetooth

struct SensorReading {
    var humidity : UInt8
    var temparature: Float
    var pressure: UInt32
    var accelerationX: Int16
    var accelerationY: Int16
    var accelerationZ: Int16
    var voltage: UInt16

    func print() -> Void {
        //Swift.print("humidity:", humidity)
        Swift.print("temparature:", temparature, "°C")
        Swift.print("pressure:", pressure, "Pa")
    }
}

// https://github.com/ruuvi/ruuvi-sensor-protocols
func parseRuuviFormat3(data: UnsafeRawPointer) -> SensorReading {
    let humidity: UInt8 = data.load(fromByteOffset: 3, as: UInt8.self)
    
    var temparature:Float = Float(data.load(fromByteOffset: 4, as: UInt8.self))
    let tempDec: UInt8 = data.load(fromByteOffset: 5, as: UInt8.self)
    if temparature < 0 {
        temparature -= Float(tempDec) / 100
    } else {
        temparature += Float(tempDec) / 100
    }
    
    let pressure: UInt32 = UInt32(data.load(fromByteOffset: 6, as: UInt16.self)) + UInt32(50 * 1000)

    let accX: Int16 = data.load(fromByteOffset: 8, as: Int16.self)
    let accY: Int16 = data.load(fromByteOffset: 10, as: Int16.self)
    let accZ: Int16 = data.load(fromByteOffset: 12, as: Int16.self)
    
    let voltage: UInt16 = data.load(fromByteOffset: 14, as: UInt16.self)

    return SensorReading(
        humidity: humidity,
        temparature: temparature,
        pressure: pressure,
        accelerationX: accX,
        accelerationY: accY,
        accelerationZ: accZ,
        voltage: voltage
    )
}

class AppDelegate: NSObject, NSApplicationDelegate, CBCentralManagerDelegate {
    var manager: CBCentralManager?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let connectable = advertisementData[CBAdvertisementDataIsConnectable] as! Bool
        if !connectable {
            let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData
            let ptr = data.bytes
            let manufacturer = ptr.load(as: UInt16.self)
            if manufacturer == 0x0499 {
                let format = ptr.load(fromByteOffset: 2, as: UInt8.self)
                if format == 3 {
                    let sensor = parseRuuviFormat3(data: ptr)
                    //sensor.print()
                    print(sensor)
                }
            }
        }
    }
}

