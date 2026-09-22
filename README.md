# ⚡ PICkit Mac

A native macOS interface for **PICkit 2 / PICkit 3**, built around the `pk2cmd` programming engine.

![macOS](https://img.shields.io/badge/macOS-13%2B-black)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![PICkit](https://img.shields.io/badge/PICkit-2%20%7C%203-red)
![Status](https://img.shields.io/badge/status-in%20development-orange)

**Native macOS GUI · Intel HEX support · Read · Write · Verify · Erase · Advanced pk2cmd controls**

---

## ✨ What is PICkit Mac?

PICkit Mac is a native SwiftUI application that provides a graphical interface for the `pk2cmd` command-line programmer.

The goal is simple: keep the flexibility of `pk2cmd`, but make the most common PIC programming operations easier to use on macOS.

Instead of manually building long terminal commands, you can configure and run operations directly from the application.

The app currently supports common workflows such as:

* 🔎 detecting a target device;
* 📖 reading device memory;
* ✍️ programming Intel HEX firmware;
* ✅ verifying firmware;
* 🧹 erasing device memory;
* 🔍 running a blank check;
* ⚡ configuring VDD and VPP;
* 💾 preserving EEPROM;
* 🧠 selecting memory regions;
* 🛠️ accessing advanced `pk2cmd` options;
* 📟 viewing the complete activity log.

---

## 🚀 Main Features

| Feature                   | Support |
| ------------------------- | :-----: |
| Native macOS interface    |    ✅    |
| PICkit 2                  |    ✅    |
| PICkit 3                  |    ✅    |
| Target auto detection     |    ✅    |
| Exact MCU selection       |    ✅    |
| Family-based detection    |    ✅    |
| Intel HEX loading         |    ✅    |
| HEX memory preview        |    ✅    |
| Read device memory        |    ✅    |
| Write firmware            |    ✅    |
| Verify firmware           |    ✅    |
| Erase memory              |    ✅    |
| Blank check               |    ✅    |
| EEPROM preservation       |    ✅    |
| VDD / VPP control         |    ✅    |
| Advanced `pk2cmd` options |    ✅    |
| Activity log              |    ✅    |
| Generated command preview |    ✅    |

---

## 🖥️ Requirements

### macOS application

* macOS **13 Ventura or newer**
* Swift **5.9+**
* Xcode or Swift command-line tools
* `pk2cmd`
* `PK2DeviceFile.dat`
* compatible PICkit programmer

The Swift package currently targets:

```text
macOS 13+
```

---

## ⚡ Quick Start

Clone the repository:

```bash
git clone <your-repository-url>
cd pickit2
```

Move into the macOS application:

```bash
cd PICkitMac
```

Build the Swift project:

```bash
swift build
```

Run it:

```bash
swift run PICkitMac
```

---

## 📦 Build the macOS App

The repository includes a build script that creates a normal `.app` bundle.

From the `PICkitMac` directory:

```bash
chmod +x build-app.sh
./build-app.sh
```

The generated application will be placed in:

```text
PICkitMac/dist/PICkit Mac.app
```

The script:

```text
Build Swift application
        ↓
Create .app bundle
        ↓
Copy pk2cmd if available
        ↓
Copy PK2DeviceFile.dat if available
        ↓
Ad-hoc codesign application
        ↓
PICkit Mac.app
```

If `pk2cmd` and `PK2DeviceFile.dat` are present in the expected project directories, they are automatically included inside the application bundle.

---

## 🔌 Getting Started

A normal programming workflow looks like this:

```text
Connect PICkit
      ↓
Connect target MCU
      ↓
Detect device
      ↓
Select HEX firmware
      ↓
Write firmware
      ↓
Verify
      ↓
Done
```

### Basic workflow

1. Connect your PICkit programmer.
2. Connect the target microcontroller.
3. Start **PICkit Mac**.
4. Make sure the `pk2cmd` engine is detected.
5. Select automatic detection or enter the exact MCU.
6. Click **Detect Device**.
7. Select an Intel HEX firmware file.
8. Click **Write Firmware**.
9. Verify the programmed device.

Destructive operations such as **Write Firmware** and **Erase Memory** require confirmation before they are executed.

---

## 🎯 Device Selection

PICkit Mac provides several ways to choose the target device.

### Automatic detection

The application can let `pk2cmd` search across supported device families.

```text
-P
```

This is the easiest option for most cases.

### Family detection

Detection can be restricted to a specific family:

```text
-PF<family>
```

### Exact part

You can also enter the exact microcontroller name:

```text
-P<part>
```

For example:

```text
-PPIC16F887
```

---

## 📂 Intel HEX Support

PICkit Mac can load standard Intel HEX firmware files.

After selecting a `.hex` file, the application generates a small memory preview showing the decoded addresses and bytes.

Example:

```text
00000000  28 00 34 12 FF FF FF FF
00000010  10 2A 05 30 A0 00 FF FF
00000020  ·· ·· ·· ·· ·· ·· ·· ··
```

The preview is intended as a quick way to confirm that the selected file contains valid Intel HEX data before programming.

---

## 🧰 Quick Operations

### 🔎 Detect Device

Detects the connected target using the selected device mode.

Keyboard shortcut:

```text
⌘D
```

---

### 📖 Read Memory

Reads the target device and saves the result to an Intel HEX file.

Keyboard shortcut:

```text
⌘R
```

The application asks where the output file should be saved.

---

### ✍️ Write Firmware

Programs the selected Intel HEX file into the target device.

Keyboard shortcut:

```text
⌘W
```

A confirmation is displayed before programming begins.

---

### ✅ Verify

Compares the selected firmware with the contents of the target.

Keyboard shortcut:

```text
⌘V
```

---

### 🧹 Erase Memory

Erases the target device.

Because this operation is destructive, the application asks for confirmation first.

---

### 🔍 Blank Check

Checks whether the selected target memory is blank.

---

## 🧠 Memory Regions

Programming and verification can be limited to specific memory areas.

Supported regions include:

| Region         | Code |
| -------------- | :--: |
| Program memory |  `P` |
| EEPROM         |  `E` |
| ID memory      |  `I` |
| Configuration  |  `C` |

For example:

```text
-MPE
```

can be used to select Program Memory and EEPROM for programming.

PICkit Mac builds these arguments automatically from the graphical controls.

---

## ⚙️ Power and Signal Controls

The Settings section provides access to several programmer power options.

### VDD

You can manually override the target voltage:

```text
-A<voltage>
```

Example:

```text
-A3.3
```

### External target power

PICkit Mac can tell `pk2cmd` that the target uses an external power supply.

### VPP

Programming voltage can also be overridden manually when required.

### Additional controls

The interface includes options for:

* keeping the target powered after an operation;
* releasing `/MCLR`;
* VPP-first programming entry;
* external power detection.

> [!CAUTION]
> Incorrect voltage settings can damage the target device. Only override VDD or VPP when you know the requirements of the connected microcontroller.

---

## 💾 EEPROM Preservation

EEPROM contents can be preserved during programming.

Enable:

```text
Preserve EEPROM
```

The generated command will include:

```text
-Z
```

This can be useful when firmware is updated without wanting to erase stored configuration or calibration data.

---

## 🛠️ Expert Mode

PICkit Mac includes an **Expert Mode** for users who need more control over `pk2cmd`.

Available options include:

* Blank Check `-C`
* Programmer firmware update `-D`
* Erase `-E`
* Read `-G`
* Exit delay `-H`
* Show Device ID `-I`
* Progress output `-J`
* Show checksum `-K`
* Programming speed `-L`
* Program `-M`
* Programmer Unit ID `-N`
* Write through last address `-O`
* Part selection `-P`
* Disable Programming Executive `-Q`
* Release `/MCLR` `-R`
* Select programmer `-S`
* Keep target powered `-T`
* OSCCAL programming `-U`
* VPP override `-V`
* External power `-W`
* VPP-first entry `-X`
* Verify `-Y`
* Preserve EEPROM `-Z`
* I²C address override `-#`

You can also enter additional raw `pk2cmd` arguments manually.

> [!WARNING]
> Expert Mode provides direct access to low-level programming options. Incorrect settings can erase data, overwrite calibration information or prevent the target from operating correctly.

---

## 💻 Generated Command Preview

One useful feature is the live command preview.

As options are changed in the interface, PICkit Mac shows the `pk2cmd` command that will actually be executed.

For example:

```bash
pk2cmd -P -Ffirmware.hex -M -Y -A5.0
```

This makes the GUI useful both as a programming tool and as a way to learn or debug `pk2cmd` commands.

---

## 📟 Activity Log

Every operation is logged inside the application.

The log shows:

* the exact command being executed;
* standard `pk2cmd` output;
* errors;
* programmer messages;
* operation status;
* process exit code.

Example:

```text
$ pk2cmd -P -Ffirmware.hex -M

Auto-Detect: Found part PIC16F887
Programming...
Programming Successful.

Exit code: 0
```

Operations can also be stopped while they are running.

---

## 🔧 Selecting the pk2cmd Engine

PICkit Mac automatically searches for `pk2cmd` in several common locations.

It checks:

```text
Application Resources/pk2cmd
./pk2cmd/pk2cmd
../pk2cmd/pk2cmd
/usr/local/bin/pk2cmd
/opt/homebrew/bin/pk2cmd
```

If it cannot find the executable automatically, you can select it manually from the application.

---

## 🗃️ PK2DeviceFile.dat

`pk2cmd` requires:

```text
PK2DeviceFile.dat
```

This file contains information about supported Microchip devices and programming algorithms.

PICkit Mac checks for it inside the project and inside the packaged application resources.

You can also select another device database manually from Settings.

---

## 🔢 Multiple Programmers

The application supports the programmer-selection features provided by `pk2cmd`.

Available modes include:

* first connected programmer;
* programmer selected by Unit ID;
* list connected programmers;
* list programmers with firmware versions.

This is useful when multiple PICkit devices are connected to the same Mac.

---

## 🏗️ Project Structure

```text
pickit2/
│
├── pk2cmd/
│   ├── cmd_app.cpp
│   ├── PICkitFunctions.cpp
│   ├── DeviceFile.cpp
│   ├── DeviceData.cpp
│   ├── ImportExportHex.cpp
│   ├── pk2usbmacosx.cpp
│   ├── PK2DeviceFile.dat
│   └── ...
│
├── PICkitMac/
│   │
│   ├── Package.swift
│   ├── build-app.sh
│   │
│   ├── Packaging/
│   │   └── Info.plist
│   │
│   └── Sources/
│       └── PICkitMac/
│           ├── PICkitMacApp.swift
│           ├── ContentView.swift
│           ├── ProgrammerModel.swift
│           ├── CommandOptions.swift
│           └── Views.swift
│
├── pk2cmd.sln
├── 60-pickit.rules
├── license.txt
└── License Agreement.rtf
```

---

## 🧩 Main Components

### `PICkitMacApp.swift`

Application entry point.

It creates the main SwiftUI window and defines keyboard shortcuts for common programmer operations.

### `ContentView.swift`

Main graphical interface.

Contains:

* programmer status;
* quick actions;
* firmware controls;
* settings;
* Expert Mode;
* activity log.

### `ProgrammerModel.swift`

Connects the SwiftUI interface to `pk2cmd`.

It handles:

* process execution;
* firmware selection;
* device detection;
* read/write/verify operations;
* validation;
* operation confirmations;
* activity logging;
* HEX preview generation.

### `CommandOptions.swift`

Converts GUI settings into valid `pk2cmd` command-line arguments.

### `Views.swift`

Contains reusable interface components used by the application.

### `pk2cmd/`

Contains the underlying PICkit command-line programming engine.

---

## 🐧 Linux USB Rules

The repository also includes:

```text
60-pickit.rules
```

with USB rules for:

* PICkit 2
* PICkit 3
* PKOB

Example IDs included in the file:

```text
PICkit 2  → 04d8:0033
PICkit 3  → 04d8:900a
PKOB      → 04d8:8107
```

These rules are relevant when using the `pk2cmd` side of the project on Linux.

---

## 🪟 Windows

The original `pk2cmd` source also contains a Visual Studio solution:

```text
pk2cmd.sln
```

The project contains Win32 configurations and uses the Windows HID and SetupAPI libraries.

The **PICkit Mac GUI itself is macOS-only**.

---

## 🛡️ Safety

Programming microcontrollers can permanently change or erase device memory.

Before writing or erasing a device:

* ✅ make sure the correct MCU is selected;
* ✅ verify the target voltage;
* ✅ confirm the correct HEX file is loaded;
* ✅ back up important EEPROM or configuration data;
* ✅ check the programmer wiring;
* ✅ make sure the target is powered correctly.

Be especially careful when modifying:

* configuration words;
* EEPROM;
* OSCCAL values;
* programming voltages;
* device calibration data.

---

## 🧪 Useful Development Commands

Build the macOS interface:

```bash
cd PICkitMac
swift build
```

Build a release version:

```bash
swift build -c release
```

Run directly with SwiftPM:

```bash
swift run PICkitMac
```

Create the `.app` bundle:

```bash
./build-app.sh
```

Run `pk2cmd` directly:

```bash
./pk2cmd/pk2cmd -?
```

Show help for an individual option:

```bash
./pk2cmd/pk2cmd -?P
```

---

## ❓ FAQ

### Is this a replacement for pk2cmd?

No.

PICkit Mac uses `pk2cmd` as its programming engine and provides a native graphical interface on top of it.

### Does it support PICkit 2?

Yes.

### Does it support PICkit 3?

The included `pk2cmd` source contains PICkit 3 support and the application exposes the same programming engine.

### Can it automatically detect my MCU?

Yes.

You can use automatic detection, family detection or enter an exact part number.

### Can I program HEX files?

Yes.

Intel HEX files can be selected, previewed, written and verified.

### Can I read firmware from a chip?

Yes.

The Read operation can save device contents to a HEX file.

### Can I preserve EEPROM?

Yes.

EEPROM preservation can be enabled before programming.

### Can I see the actual pk2cmd command?

Yes.

The application generates a live command preview based on the options selected in the GUI.

### What happens if pk2cmd is missing?

The app will report that the programming engine is unavailable and lets you select the executable manually.

### What happens if PK2DeviceFile.dat is missing?

`pk2cmd` cannot correctly load its device database. You can select the location manually from the Settings section.

---

## 🤝 Contributing

Contributions and testing are welcome.

Useful areas include:

* 🍎 macOS UI improvements;
* 🔌 PICkit USB compatibility;
* 🐛 bug fixes;
* 🧠 device detection improvements;
* 📟 better `pk2cmd` output parsing;
* 🧪 testing with additional PIC devices;
* ⚙️ packaging improvements;
* 📚 documentation.

For bug reports, useful information includes:

```text
macOS version:
Mac: Intel / Apple Silicon
Programmer: PICkit 2 / PICkit 3
Target MCU:
Operation:
pk2cmd exit code:
Expected result:
Actual result:
```

Including the relevant Activity Log output can make troubleshooting much easier.

---

## 📜 License

This repository contains code originating from Microchip's `pk2cmd` software.

The included source files contain Microchip's original license terms, including restrictions concerning use with **Microchip products**.

Before redistributing or modifying the project, read:

```text
license.txt
License Agreement.rtf
```

and the license notices included in the source files.

The SwiftUI frontend should also be distributed in a way that remains compatible with those terms.

---

## ⚠️ Disclaimer

PICkit Mac is a programming utility intended for development and experimentation with supported Microchip devices.

Programming, erasing or changing configuration memory can make a target device stop working if incorrect settings or firmware are used.

Always verify the selected device, firmware and voltage settings before starting an operation.

---

## ⭐ Support the Project

If you find the project useful:

* ⭐ Star the repository
* 🐛 Report bugs
* 🔧 Submit improvements
* 🧪 Test additional PIC devices
* 📟 Share useful `pk2cmd` compatibility results
* 🤝 Open a pull request

---

**PICkit Mac — a native macOS interface for the classic PICkit programming workflow.**
