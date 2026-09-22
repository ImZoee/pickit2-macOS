import SwiftUI

@main
struct PICkitMacApp: App {
    @StateObject private var model = ProgrammerModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 1080, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("Programmer") {
                Button("Detect Device") { model.request(.detect) }
                    .keyboardShortcut("d", modifiers: [.command])
                Divider()
                Button("Read…") { model.request(.read) }
                    .keyboardShortcut("r", modifiers: [.command])
                Button("Write Firmware") { model.request(.write) }
                    .keyboardShortcut("w", modifiers: [.command])
                Button("Verify") { model.request(.verify) }
                    .keyboardShortcut("v", modifiers: [.command])
                Button("Erase Memory") { model.request(.erase) }
                Button("Blank Check") { model.request(.blankCheck) }
            }
        }
    }
}
