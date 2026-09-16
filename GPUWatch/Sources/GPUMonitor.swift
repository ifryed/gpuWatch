import Foundation
import IOKit

@MainActor
final class GPUMonitor: ObservableObject {
    @Published private(set) var utilization: Double = 0
    @Published private(set) var memoryUsedBytes: UInt64 = 0
    @Published private(set) var memoryAllocatedBytes: UInt64 = 0
    @Published private(set) var gpuName: String = "GPU"
    @Published private(set) var totalSystemMemoryBytes: UInt64 = ProcessInfo.processInfo.physicalMemory

    var memoryUsedGB: Double {
        Double(memoryUsedBytes) / 1_073_741_824.0
    }

    var memoryAllocatedGB: Double {
        Double(memoryAllocatedBytes) / 1_073_741_824.0
    }

    var totalSystemMemoryGB: Double {
        Double(totalSystemMemoryBytes) / 1_073_741_824.0
    }

    var memoryPercent: Double {
        let cap = memoryAllocatedBytes > 0 ? memoryAllocatedBytes : totalSystemMemoryBytes
        guard cap > 0 else { return 0 }
        return min(100, max(0, Double(memoryUsedBytes) / Double(cap) * 100))
    }

    private var timer: Timer?

    func start() {
        sample()
        let timer = Timer(timeInterval: 0.6, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.sample()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sample() {
        guard let snapshot = Self.readSnapshot() else { return }
        utilization = snapshot.utilization
        memoryUsedBytes = snapshot.memoryUsed
        memoryAllocatedBytes = snapshot.memoryAllocated
        gpuName = snapshot.name
        totalSystemMemoryBytes = ProcessInfo.processInfo.physicalMemory
    }

    nonisolated private static func readSnapshot() -> Snapshot? {
        var iterator: io_iterator_t = 0
        guard let matching = IOServiceMatching("IOAccelerator") else { return nil }
        let status = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard status == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        var snapshot: Snapshot?
        var service = IOIteratorNext(iterator)
        while service != 0 {
            let current = service
            service = IOIteratorNext(iterator)
            defer { IOObjectRelease(current) }

            guard snapshot == nil else { continue }

            var propertiesRef: Unmanaged<CFMutableDictionary>?
            guard IORegistryEntryCreateCFProperties(current, &propertiesRef, kCFAllocatorDefault, 0) == KERN_SUCCESS,
                  let properties = propertiesRef?.takeRetainedValue() as? [String: Any],
                  let stats = properties["PerformanceStatistics"] as? [String: Any]
            else { continue }

            let device = numeric(stats["Device Utilization %"])
            let renderer = numeric(stats["Renderer Utilization %"])
            let tiler = numeric(stats["Tiler Utilization %"])
            let utilization = min(100, max(0, max(device, renderer, tiler)))

            let used = uint64(stats["In use system memory"])
                ?? uint64(stats["vramUsedBytes"])
                ?? 0
            let allocated = uint64(stats["Alloc system memory"])
                ?? uint64(stats["vramFreeBytes"]).map { $0 + used }
                ?? used

            let name = (properties["model"] as? String)
                ?? (properties["IOClass"] as? String)
                ?? "GPU"

            snapshot = Snapshot(
                name: name,
                utilization: utilization,
                memoryUsed: used,
                memoryAllocated: allocated
            )
        }

        return snapshot
    }

    nonisolated private static func numeric(_ value: Any?) -> Double {
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        case let int as Int:
            return Double(int)
        case let double as Double:
            return double
        default:
            return 0
        }
    }

    nonisolated private static func uint64(_ value: Any?) -> UInt64? {
        switch value {
        case let number as NSNumber:
            return number.uint64Value
        case let int as Int:
            return UInt64(int)
        case let value as UInt64:
            return value
        default:
            return nil
        }
    }

    private struct Snapshot {
        let name: String
        let utilization: Double
        let memoryUsed: UInt64
        let memoryAllocated: UInt64
    }
}
