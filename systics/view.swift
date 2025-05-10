
import SwiftUI
import Metal

struct MainView: View {
    
    let device = MTLCreateSystemDefaultDevice();
    let processInfo = ProcessInfo.processInfo
    let memory = systemMemoryStats();
    let displays = getDisplayInformation();
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Diagnostics:").padding(.bottom, 10).fontWeight(.bold)
                    Text("Mac Name: \(processInfo.hostName)")
                    Text("OSX Version: \(processInfo.operatingSystemVersionString)")
                    Text("Processor Count: \(processInfo.processorCount)")
                    Text("Active Processor Count: \(processInfo.activeProcessorCount)")
                    Text("Total Physical Memory: \(ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory))")
                    if (!memory.isEmpty) {
                        Text("Free: \(ByteCountFormatter.string(fromByteCount: Int64(memory[0]), countStyle: .memory))")
                        Text("Active: \(ByteCountFormatter.string(fromByteCount: Int64(memory[1]), countStyle: .memory))")
                        Text("Inactive: \(ByteCountFormatter.string(fromByteCount: Int64(memory[2]), countStyle: .memory))")
                        Text("Wired: \(ByteCountFormatter.string(fromByteCount: Int64(memory[3]), countStyle: .memory))")
                        Text("Compressed: \(ByteCountFormatter.string(fromByteCount: Int64(memory[4]), countStyle: .memory))")
                    }
                    Text("Thermal State: \(processInfo.thermalState)")
                    Text("Temperature: \(getTemperature())")
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("GPU Diagnostics:").padding(.bottom, 10).fontWeight(.bold)
                    if let device = device {
                        Text("Metal Device: \(device.name)")
                        Text("Unified Memory: \(device.hasUnifiedMemory ? "Yes" : "No")")
                        Text("Current Allocated Size: \(ByteCountFormatter.string(fromByteCount: Int64(device.currentAllocatedSize), countStyle: .memory))")
                        Text("Recommended working set: \(ByteCountFormatter.string(fromByteCount: Int64(device.recommendedMaxWorkingSetSize), countStyle: .memory))")
                        Text("Max Threadgroup Memory Length: \(device.maxThreadgroupMemoryLength) bytes")
                        Text("Max Threads Per Threadgroup: \(device.maxThreadsPerThreadgroup.width)x\(device.maxThreadsPerThreadgroup.height)x\(device.maxThreadsPerThreadgroup.depth)")
                        Text("Supports Apple Family 1: \(device.supportsFamily(.apple1))")
                        Text("Supports Apple Family 2: \(device.supportsFamily(.apple2))")
                        Text("Supports Ray Tracing: \(device.supportsRaytracing)")
                        Text("Supports Function Pointers: \(device.supportsFunctionPointers)")
                        Text("Supports Dynamic Libraries: \(device.supportsDynamicLibraries)")
                        Text("Registry ID: \(device.registryID)")
                        Text("Supports Raster Order Groups: \(device.areRasterOrderGroupsSupported)")
                    }
                    else {
                        Text("Unable to retrieve GPU information. Sorry :(")
                    }
                }
            }
            HStack() {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Display Diagnostics: ")
                        .padding(.bottom, 10)
                        .fontWeight(.bold)
                    ForEach(displays.indices, id: \.self) { index in
                        let display = displays[index]
                        Text("ID: \(display.displayID)")
                        Text("Resolution: \(display.resolution)")
                        Text("Refresh Rate: \(String(describing: display.refreshRate)) Hz")
                        Text("Pixel Format: \(display.pixelFormat)")
                        Text("Builtin: \(display.isBuiltIn == 1 ? "Yes" : "No")")
                    }
                }
                Spacer()
            }        }
        .padding(.leading, 40)
        .padding(.trailing, 40)
        .padding(.top, 80)
        .padding(.bottom, 80)
        .frame(width: 600, height: 500)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}



#Preview {
    MainView()
}
