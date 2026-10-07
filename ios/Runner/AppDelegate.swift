import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      let audioChannel = FlutterMethodChannel(
        name: "ph.eparada.mobile/audio_routing",
        binaryMessenger: controller.binaryMessenger
      )
      audioChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "setSpeakerphoneOn" {
          let args = call.arguments as? [String: Any]
          let enable = (args?["enable"] as? Bool) ?? false
          AppDelegate.setSpeakerphone(enable: enable)
          result(true)
        } else if call.method == "resetAudioRoute" {
          AppDelegate.resetAudioRoute()
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    return result
  }

  static func setSpeakerphone(enable: Bool) {
    let session = AVAudioSession.sharedInstance()
    do {
      // Configure audio session without .defaultToSpeaker so normal earpiece speaker is the default!
      try session.setCategory(
        .playAndRecord,
        mode: .voiceChat,
        options: [.allowBluetooth, .allowBluetoothA2DP]
      )
      try session.setActive(true)
      if enable {
        try session.overrideOutputAudioPort(.speaker)
      } else {
        try session.overrideOutputAudioPort(.none)
      }
    } catch {
      print("iOS Audio routing error: \(error)")
    }
  }

  static func resetAudioRoute() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.overrideOutputAudioPort(.none)
      try session.setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      print("iOS Audio reset error: \(error)")
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
