import UIKit
import Flutter
import flutter_downloader
//import FirebaseAppCheck
//import FirebaseCore

//class NSCAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
//    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
//        if #available(iOS 14.0, *) {
//            return AppAttestProvider(app: app)
//        } else {
//            return nil
//        }
//    }
//}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
//    let providerFactory = NSCAppCheckProviderFactory()
//    AppCheck.setAppCheckProviderFactory(providerFactory)

    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
