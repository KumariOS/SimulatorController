# Simulator Controller

A Mac OS X application that boots, installs and launches a .app on multiple iOS simulators.

Uses [FBSimulatorControl](https://github.com/facebook/FBSimulatorControl) to interface with the simulators.

![Screenshot](screenshot.png)

## Installation

[Download the latest version here](https://github.com/davidlawson/SimulatorController/releases/download/v1.0/SimulatorController.app.zip).

## Usage

Drag your iOS application's .app from the Products folder in your Xcode project to Simulator Controller.

Select the simulators you want to launch, then press Boot or Boot & Install.

When you have made changes to your app, rebuild it then press Install to reinstall it on the simulators.

*AppleScript support (for automatic reinstall on build) coming soon.*

## Building

Run `carthage bootstrap` to download and build the FBSimulatorControl framework.
