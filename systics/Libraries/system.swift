
import IOKit
import CoreGraphics
import Foundation

func  systemMemoryStats() -> [UInt64] {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

    let hostPort: mach_port_t = mach_host_self()
    let result = withUnsafeMutablePointer(to: &stats) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
        }
    }

    guard result == KERN_SUCCESS else {
        return []
    }

    let pageSize = vm_kernel_page_size

    let free = UInt64(stats.free_count) * UInt64(pageSize)
    let active = UInt64(stats.active_count) * UInt64(pageSize)
    let inactive = UInt64(stats.inactive_count) * UInt64(pageSize)
    let wired = UInt64(stats.wire_count) * UInt64(pageSize)
    let compressed = UInt64(stats.compressor_page_count) * UInt64(pageSize)

    return [free, active, inactive, wired, compressed]
}

func getTemperature() -> String {
    let serviceName = "AppleSmartBattery"
    guard let matchingDict = IOServiceMatching(serviceName) else {
        return "Failed to create matching dictionary"
    }

    var iterator: io_iterator_t = 0
    let kernResult = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
    if kernResult != KERN_SUCCESS {
        return "Failed to get matching services"
    }

    var service: io_object_t = 0
    var temperature: Float = 0.0

    while true {
        service = IOIteratorNext(iterator)
        if service == 0 {
            break
        }

        let temperatureKey = "Temperature" as CFString
        if let cfTemp = IORegistryEntryCreateCFProperty(service, temperatureKey, kCFAllocatorDefault, 0) {
            let value = cfTemp.takeUnretainedValue()
            if let number = value as? NSNumber {
                temperature = number.floatValue / 100.0 // might be in 0.01°C units
                IOObjectRelease(service)
                IOObjectRelease(iterator)
                return String(format: "%.1f°C", temperature)
            }
        }

        IOObjectRelease(service)
    }

    IOObjectRelease(iterator)
    return "Temperature not found"
}

struct DisplayInfo {
    var displayID: CGDirectDisplayID
    var resolution: (width: Int, height: Int)
    var pixelFormat: (width: Int, height: Int)
    var refreshRate: Double
    var isBuiltIn: Int32
}

func getDisplayInformation() -> [DisplayInfo] {
    var displayCount: UInt32 = 0
    var displays: [CGDirectDisplayID] = []
    
    CGGetActiveDisplayList(0, nil, &displayCount)
    displays = Array(repeating: 0, count: Int(displayCount))
    CGGetActiveDisplayList(displayCount, &displays, &displayCount)
    
    var displayInfoArray: [DisplayInfo] = []
    
    for display in displays {
        let bounds = CGDisplayBounds(display)
        let displayMode = CGDisplayCopyDisplayMode(display)
        let refreshRate = displayMode?.refreshRate
        let isBuiltin = CGDisplayIsBuiltin(display)
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        let pixelWidth = displayMode?.pixelWidth ?? 0
        let pixelHeight = displayMode?.pixelHeight ?? 0

        let displayInfo = DisplayInfo(
            displayID: display,
            resolution: (width, height),
            pixelFormat: (pixelWidth, pixelHeight),
            refreshRate: refreshRate ?? 0,
            isBuiltIn: isBuiltin
        )
        
        displayInfoArray.append(displayInfo)
    }
    
    return displayInfoArray
}

