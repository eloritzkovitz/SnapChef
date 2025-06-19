import Flutter
import UIKit
import Firebase
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialize Firebase only if not already configured
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // Debugging config.plist loading
    if let configPath = Bundle.main.path(forResource: "config", ofType: "plist") {
        print("Config.plist path: \(configPath)")
        if let configContents = NSDictionary(contentsOfFile: configPath) {
            print("Config.plist contents: \(configContents)")
        } else {
            print("Failed to load contents of config.plist")
        }
    } else {
        print("Config.plist not found in bundle")
    }

    // Load configuration from config.plist
    guard let configPath = Bundle.main.path(forResource: "config", ofType: "plist"),
          let config = NSDictionary(contentsOfFile: configPath) as? [String: Any],
          let clientID = config["GOOGLE_CLIENT_ID"] as? String,
          let urlScheme = config["GOOGLE_CLIENT_ID_SCHEME"] as? String else {
      fatalError("Failed to load GOOGLE_CLIENT_ID or GOOGLE_CLIENT_ID_SCHEME from config.plist.")
    }

    let signInConfig = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = signInConfig

    // Ensure the URL scheme is registered
    if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
       let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String],
       !urlSchemes.contains(urlScheme) {
      fatalError("URL scheme \(urlScheme) is not registered in Info.plist")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
