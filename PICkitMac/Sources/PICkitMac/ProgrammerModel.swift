import AppKit
import Foundation

enum QuickOperation: String, Identifiable {
    case detect, read, write, verify, erase, blankCheck
    var id: String { rawValue }

    var title: String {
        switch self {
        case .detect: return "Detect Device"
        case .read: return "Read Memory"
        case .write: return "Write Firmware"
        case .verify: return "Verify Firmware"
        case .erase: return "Erase Memory"
        case .blankCheck: return "Blank Check"
        }
    }
}

@MainActor
final class ProgrammerModel: ObservableObject {
    @Published var options = CommandOptions()
    @Published var executablePath = ""
    @Published var console = "The application is ready. Connect the programmer and detect the target device.\n"
    @Published var status = "Programmer not detected"
    @Published var isRunning = false
    @Published var exitCode: Int32?
    @Published var memoryPreview: [String] = []
    @Published var selectedTab = 0
    @Published var pendingConfirmation: QuickOperation?
    @Published var alertMessage: String?

    private var process: Process?

    init() {
        executablePath = Self.findExecutable() ?? ""
        let fm = FileManager.default
        let bundledDeviceFile = Bundle.main.resourceURL.map {
            $0.appendingPathComponent("PK2DeviceFile.dat").path(percentEncoded: false)
        }
        let deviceFileCandidates = [
            fm.currentDirectoryPath + "/pk2cmd/PK2DeviceFile.dat",
            fm.currentDirectoryPath + "/../pk2cmd/PK2DeviceFile.dat",
            bundledDeviceFile
        ] as [String?]
        if let deviceFile = deviceFileCandidates.compactMap({ $0 }).first(where: fm.fileExists(atPath:)) {
            options.deviceFilePath = URL(fileURLWithPath: deviceFile).deletingLastPathComponent().path(percentEncoded: false)
        }
    }

    var commandPreview: String {
        ([executablePath.isEmpty ? "pk2cmd" : executablePath] + options.arguments())
            .map(\.shellQuoted).joined(separator: " ")
    }

    var isEngineReady: Bool {
        !executablePath.isEmpty && FileManager.default.isExecutableFile(atPath: executablePath)
    }

    var hasFirmware: Bool {
        !options.hexFilePath.isEmpty && FileManager.default.fileExists(atPath: options.hexFilePath)
    }

    var selectedTarget: String {
        switch options.partSelection {
        case .explicit: return options.partName.isEmpty ? "Not selected" : options.partName.uppercased()
        case .autoAll: return "Automatic detection"
        case .autoFamily: return options.familyID.isEmpty ? "Family not specified" : "Family \(options.familyID)"
        case .none: return "Not selected"
        }
    }

    func request(_ operation: QuickOperation) {
        guard !isRunning else { return }
        if let problem = validationProblem(for: operation) {
            alertMessage = problem
            return
        }
        if operation == .write || operation == .erase {
            pendingConfirmation = operation
        } else {
            runQuick(operation)
        }
    }

    func confirmPendingOperation() {
        guard let operation = pendingConfirmation else { return }
        pendingConfirmation = nil
        runQuick(operation)
    }

    func validationProblem(for operation: QuickOperation) -> String? {
        guard isEngineReady else {
            return "The pk2cmd engine is unavailable. Select the executable in Settings."
        }
        if operation == .write || operation == .verify {
            guard hasFirmware else { return "Select a valid Intel HEX firmware file first." }
        }
        if options.partSelection == .autoFamily && options.familyID.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Enter a family ID or select automatic detection across all families."
        }
        if operation != .detect && options.partSelection == .explicit && options.partName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Enter the exact microcontroller part number or enable automatic detection."
        }
        return nil
    }

    func chooseExecutable() {
        let panel = NSOpenPanel()
        panel.title = "Select the pk2cmd Executable"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK { executablePath = panel.url?.path ?? "" }
    }

    func chooseHexFile() {
        let panel = NSOpenPanel()
        panel.title = "Select Intel HEX Firmware"
        panel.allowedContentTypes = [.init(filenameExtension: "hex")].compactMap { $0 }
        if panel.runModal() == .OK, let path = panel.url?.path {
            options.hexFilePath = path
            loadPreview(path: path)
        }
    }

    func chooseDeviceFile() {
        let panel = NSOpenPanel()
        panel.title = "Select PK2DeviceFile.dat"
        if panel.runModal() == .OK, let url = panel.url {
            options.deviceFilePath = url.deletingLastPathComponent().path(percentEncoded: false)
        }
    }

    func chooseFirmware() {
        let panel = NSOpenPanel()
        panel.title = "Select Programmer Firmware"
        if panel.runModal() == .OK { options.firmwarePath = panel.url?.path ?? "" }
    }

    func runQuick(_ operation: QuickOperation) {
        guard !isRunning else { return }
        var args = baseArguments()
        switch operation {
        case .detect:
            args += partArgument()
        case .read:
            let panel = NSSavePanel()
            panel.title = "Save Device Contents"
            panel.nameFieldStringValue = "device-read.hex"
            guard panel.runModal() == .OK, let path = panel.url?.path else { return }
            args += partArgument() + ["-GF\(path)"]
        case .write:
            guard requireHexFile() else { return }
            args += partArgument() + ["-F\(options.hexFilePath)", "-M"]
        case .verify:
            guard requireHexFile() else { return }
            args += partArgument() + ["-F\(options.hexFilePath)", "-Y"]
        case .erase:
            args += partArgument() + ["-E"]
        case .blankCheck:
            args += partArgument() + ["-C"]
        }
        if options.overrideVDD { args.append("-A\(options.vdd)") }
        if options.externalPower { args.append("-W\(options.externalPowerThreshold)") }
        if options.releaseMCLR { args.append("-R") }
        if options.powerAfter { args.append("-T") }
        run(arguments: args)
    }

    func runConfigured() { run(arguments: options.arguments()) }

    func showHelp(_ option: String = "") {
        run(arguments: ["-?\(option)"])
        selectedTab = 3
    }

    func stop() {
        process?.terminate()
        console += "\nOperation cancelled by the user.\n"
    }

    private func baseArguments() -> [String] {
        options.deviceFilePath.isEmpty ? [] : ["-B\(options.deviceFilePath)"]
    }

    private func partArgument() -> [String] {
        switch options.partSelection {
        case .explicit: return options.partName.isEmpty ? ["-P"] : ["-P\(options.partName)"]
        case .autoAll: return ["-P"]
        case .autoFamily: return ["-PF\(options.familyID)"]
        case .none: return []
        }
    }

    private func requireHexFile() -> Bool {
        guard !options.hexFilePath.isEmpty else {
            status = "Select firmware first"
            chooseHexFile()
            return !options.hexFilePath.isEmpty
        }
        return true
    }

    private func run(arguments: [String]) {
        guard !executablePath.isEmpty else {
            status = "The pk2cmd engine is not configured"
            console += "\nSelect the pk2cmd executable in Settings.\n"
            selectedTab = 3
            return
        }
        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            status = "Invalid pk2cmd executable"
            console += "\nThe selected file is not executable: \(executablePath)\n"
            selectedTab = 3
            return
        }

        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: executablePath)
        task.arguments = arguments
        task.standardOutput = pipe
        task.standardError = pipe
        task.currentDirectoryURL = URL(fileURLWithPath: executablePath).deletingLastPathComponent()

        console = "$ " + ([executablePath] + arguments).map(\.shellQuoted).joined(separator: " ") + "\n\n"
        status = "Operation in progress…"
        isRunning = true
        exitCode = nil
        process = task

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.async { self?.console += text }
        }
        task.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                pipe.fileHandleForReading.readabilityHandler = nil
                self?.isRunning = false
                self?.exitCode = process.terminationStatus
                switch process.terminationStatus {
                case 0:
                    self?.status = "Operation completed successfully"
                case 36:
                    self?.status = "Invalid command (code 36) — see the activity log"
                    self?.selectedTab = 3
                default:
                    self?.status = "Operation failed (code \(process.terminationStatus))"
                    self?.selectedTab = 3
                }
                self?.process = nil
            }
        }

        do { try task.run() }
        catch {
            pipe.fileHandleForReading.readabilityHandler = nil
            isRunning = false
            status = "The pk2cmd engine could not be started"
            console += "Launch error: \(error.localizedDescription)\n"
        }
    }

    private func loadPreview(path: String) {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else {
            memoryPreview = ["The selected file could not be read."]
            return
        }
        memoryPreview = IntelHexPreview.make(from: text)
    }

    private static func findExecutable() -> String? {
        let fm = FileManager.default
        let bundled = Bundle.main.resourceURL.map {
            $0.appendingPathComponent("pk2cmd").path(percentEncoded: false)
        }
        let candidates: [String] = ([
            bundled,
            fm.currentDirectoryPath + "/pk2cmd/pk2cmd",
            fm.currentDirectoryPath + "/../pk2cmd/pk2cmd",
            "/usr/local/bin/pk2cmd", "/opt/homebrew/bin/pk2cmd"
        ] as [String?]).compactMap { $0 }
        return candidates.first(where: fm.isExecutableFile(atPath:))
    }
}

enum IntelHexPreview {
    static func make(from text: String) -> [String] {
        var bytes: [UInt32: UInt8] = [:]
        var base: UInt32 = 0
        for line in text.split(whereSeparator: \.isNewline) {
            let value = String(line)
            guard value.first == ":", value.count >= 11 else { continue }
            let chars = Array(value.dropFirst())
            func hex(_ start: Int, _ count: Int) -> UInt32? {
                guard start + count <= chars.count else { return nil }
                return UInt32(String(chars[start..<(start + count)]), radix: 16)
            }
            guard let count = hex(0, 2), let address = hex(2, 4), let type = hex(6, 2) else { continue }
            if type == 0 {
                for index in 0..<Int(count) {
                    if let byte = hex(8 + index * 2, 2) { bytes[base + address + UInt32(index)] = UInt8(byte) }
                }
            } else if type == 4, let upper = hex(8, 4) { base = upper << 16 }
        }
        guard let minimum = bytes.keys.min(), let maximum = bytes.keys.max() else {
            return ["The file does not contain valid Intel HEX records."]
        }
        let first = minimum & ~0x0F
        let last = min(maximum, first + 0x3FF)
        return stride(from: first, through: last, by: 16).map { address in
            let values = (0..<16).map { offset in bytes[address + UInt32(offset)].map { String(format: "%02X", $0) } ?? "··" }
            return String(format: "%08X  ", address) + values.joined(separator: " ")
        }
    }
}
