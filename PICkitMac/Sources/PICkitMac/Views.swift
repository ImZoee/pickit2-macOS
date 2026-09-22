import SwiftUI

struct MemoryView: View {
    @EnvironmentObject private var model: ProgrammerModel
    var body: some View {
        VStack(spacing: 12) {
            GroupBox {
                HStack {
                    Toggle("Program Memory", isOn: $model.options.programRegions.program).toggleStyle(.checkbox)
                    Toggle("EEPROM", isOn: $model.options.programRegions.eeprom).toggleStyle(.checkbox)
                    Toggle("User IDs", isOn: $model.options.programRegions.ids).toggleStyle(.checkbox)
                    Toggle("Configuration Bits", isOn: $model.options.programRegions.configuration).toggleStyle(.checkbox)
                    Spacer()
                    Text("HEX Preview · First 1 KB").font(.caption).foregroundStyle(.secondary)
                }
            }
            GroupBox {
                ScrollView([.horizontal, .vertical]) {
                    LazyVStack(alignment: .leading, spacing: 3) {
                        if model.memoryPreview.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "doc.text.magnifyingglass").font(.system(size: 34)).foregroundStyle(.secondary)
                                Text("No Firmware Selected").font(.headline)
                                Text("Select an Intel HEX file to inspect its contents.").foregroundStyle(.secondary)
                            }.frame(maxWidth: .infinity, minHeight: 260)
                        } else {
                            ForEach(Array(model.memoryPreview.enumerated()), id: \.offset) { _, line in
                                Text(line).font(.system(.body, design: .monospaced)).textSelection(.enabled)
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(8)
                }
            }.frame(maxHeight: .infinity)
        }.padding(.vertical, 10)
    }
}

struct ConfigurationView: View {
    @EnvironmentObject private var model: ProgrammerModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SettingsCard("Power and Signals", icon: "bolt.fill") {
                    Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                        GridRow { Toggle("Set VDD manually", isOn: $model.options.overrideVDD); TextField("Volts", text: $model.options.vdd).frame(width: 90) }
                        GridRow { Toggle("Target uses external power", isOn: $model.options.externalPower); TextField("Optional threshold", text: $model.options.externalPowerThreshold).frame(width: 140) }
                        GridRow { Toggle("Set VPP manually", isOn: $model.options.overrideVPP); TextField("Volts", text: $model.options.vpp).frame(width: 90) }
                        GridRow { Toggle("Use VPP-first programming entry", isOn: $model.options.vppFirst); EmptyView() }
                        GridRow { Toggle("Keep target powered after operation", isOn: $model.options.powerAfter); Toggle("Release /MCLR pin", isOn: $model.options.releaseMCLR) }
                    }.toggleStyle(.checkbox)
                }
                SettingsCard("Programming Behavior", icon: "gearshape.2.fill") {
                    VStack(alignment: .leading, spacing: 9) {
                        Toggle("Preserve EEPROM contents", isOn: $model.options.preserveEEPROM)
                        Toggle("Write blank areas through the last used address", isOn: $model.options.writeAllThroughLastAddress)
                        Toggle("Disable Programming Executive for PIC24/dsPIC33", isOn: $model.options.disablePE)
                        Toggle("Immediately verify each programmed region", isOn: $model.options.immediateVerify)
                        HStack { Text("Programming speed"); Slider(value: Binding(get: { Double(model.options.programmingSpeed) }, set: { model.options.programmingSpeed = Int($0) }), in: 1...16, step: 1); Text("Level \(model.options.programmingSpeed)").monospacedDigit().frame(width: 55) }
                    }.toggleStyle(.checkbox)
                }
                SettingsCard("System Files", icon: "folder.fill") {
                    PathRow(label: "Device Database", path: model.options.deviceFilePath, action: model.chooseDeviceFile)
                    PathRow(label: "Programmer Firmware", path: model.options.firmwarePath, action: model.chooseFirmware)
                }
            }.padding(.vertical, 10)
        }
    }
}

struct AdvancedView: View {
    @EnvironmentObject private var model: ProgrammerModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.shield.fill").foregroundStyle(.orange)
                    Text("Expert Mode provides direct access to every pk2cmd command. Use it only if you understand the effects of the selected options.")
                        .font(.callout)
                }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                SettingsCard("Advanced Operations · C, E, G, M, Y", icon: "play.square.stack") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Toggle("Blank Check (-C)", isOn: $model.options.blankCheck); Toggle("Erase (-E)", isOn: $model.options.erase); Toggle("Program (-M)", isOn: $model.options.program); Toggle("Verify (-Y)", isOn: $model.options.verify) }.toggleStyle(.checkbox)
                        RegionEditor(title: "Program Regions", regions: $model.options.programRegions)
                        RegionEditor(title: "Verify Regions", regions: $model.options.verifyRegions)
                        Divider()
                        HStack {
                            Toggle("Read (-G)", isOn: $model.options.readEnabled).toggleStyle(.checkbox)
                            Picker("", selection: $model.options.readMode) { ForEach(ReadMode.allCases) { Text($0.rawValue).tag($0) } }.labelsHidden().frame(width: 170)
                            if model.options.readMode.needsPath { TextField("Output file path", text: $model.options.readPath) }
                            if model.options.readMode.supportsRange { TextField("HEX range x-y", text: $model.options.readRange) }
                        }
                    }
                }
                SettingsCard("Identification and Output · H, I, J, K, N, S", icon: "text.viewfinder") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Toggle("Show Device ID (-I)", isOn: $model.options.showDeviceID); Toggle("Show Checksum (-K)", isOn: $model.options.showChecksum); Toggle("Report Progress (-J)", isOn: $model.options.progressUpdates); TextField("N / lines", text: $model.options.progressLines).frame(width: 90) }.toggleStyle(.checkbox)
                        HStack { Text("Programmer to use"); Picker("", selection: $model.options.unitSelection) { ForEach(UnitSelection.allCases) { Text($0.rawValue).tag($0) } }.labelsHidden(); if model.options.unitSelection == .unitID { TextField("Programmer ID", text: $model.options.unitID) } }
                        HStack { Toggle("Assign Programmer ID (-N)", isOn: $model.options.setUnitID).toggleStyle(.checkbox); TextField("Maximum 14 characters", text: $model.options.newUnitID).disabled(!model.options.setUnitID) }
                        HStack { Text("Exit delay (-H)"); TextField("seconds or K", text: $model.options.exitDelay).frame(width: 150); Spacer() }
                    }
                }
                SettingsCard("Calibration and Serial EEPROM · U, #", icon: "waveform.path.ecg") {
                    HStack {
                        Toggle("Program OSCCAL (-U)", isOn: $model.options.programOSCCAL).toggleStyle(.checkbox)
                        TextField("HEX value", text: $model.options.osccal).frame(width: 120)
                        Divider().frame(height: 20)
                        Toggle("I²C Address (-#)", isOn: $model.options.overrideI2CAddress).toggleStyle(.checkbox)
                        TextField("0…7 or 0x08…0x77", text: $model.options.i2cAddress).frame(width: 160)
                    }
                }
                SettingsCard("Additional CLI Arguments", icon: "terminal.fill") {
                    TextField("Additional pk2cmd arguments", text: $model.options.rawArguments)
                    Text("Intended for troubleshooting and uncommon combinations. Arguments are passed directly to pk2cmd; no shell is used.").font(.caption).foregroundStyle(.secondary)
                }
                SettingsCard("Generated Command", icon: "chevron.left.forwardslash.chevron.right") {
                    ScrollView(.horizontal) { Text(model.commandPreview).font(.system(.callout, design: .monospaced)).textSelection(.enabled).padding(.vertical, 4) }
                    HStack {
                        Button("Run Configured Command") { model.runConfigured(); model.selectedTab = 3 }.buttonStyle(.borderedProminent).disabled(model.isRunning)
                        Menu("Help for Option") {
                            ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ#"), id: \.self) { option in Button(String(option)) { model.showHelp(String(option)) } }
                        }
                        Spacer()
                    }
                }
            }.padding(.vertical, 10)
        }
    }
}

struct ConsoleView: View {
    @EnvironmentObject private var model: ProgrammerModel
    var body: some View {
        VStack(spacing: 8) {
            HStack { Text("pk2cmd Activity Log").font(.headline); Spacer(); if let code = model.exitCode { Text("Exit code: \(code)").font(.caption).foregroundStyle(code == 0 ? .green : .red) }; Button("Clear Log") { model.console = "" } }
            ScrollView([.horizontal, .vertical]) {
                Text(model.console.isEmpty ? "No operations have been logged yet." : model.console)
                    .font(.system(.callout, design: .monospaced)).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading).padding(12)
            }.background(Color(nsColor: .textBackgroundColor)).clipShape(RoundedRectangle(cornerRadius: 8))
        }.padding(.vertical, 10)
    }
}

private struct RegionEditor: View {
    let title: String
    @Binding var regions: MemoryRegions
    var body: some View {
        HStack { Text(title).frame(width: 130, alignment: .leading); Toggle("Program", isOn: $regions.program); Toggle("EEPROM", isOn: $regions.eeprom); Toggle("IDs", isOn: $regions.ids); Toggle("Configuration", isOn: $regions.configuration); Text(regions.isEmpty ? "all" : regions.suffix).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary) }.toggleStyle(.checkbox)
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String, icon: String, content: Content
    init(_ title: String, icon: String, @ViewBuilder content: () -> Content) { self.title = title; self.icon = icon; self.content = content() }
    var body: some View { GroupBox { VStack(alignment: .leading, spacing: 10) { Label(title, systemImage: icon).font(.headline); Divider(); content }.frame(maxWidth: .infinity, alignment: .leading).padding(4) } }
}

private struct PathRow: View {
    let label: String, path: String, action: () -> Void
    var body: some View { HStack { Text(label).frame(width: 140, alignment: .leading); Text(path.isEmpty ? "Not selected" : path).lineLimit(1).truncationMode(.middle).foregroundStyle(path.isEmpty ? .secondary : .primary); Spacer(); Button("Select…", action: action) } }
}
