import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import PushKit
import flutter_callkit_incoming


@main
@objc class AppDelegate: FlutterAppDelegate,PKPushRegistryDelegate {
  


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // Register for VoIP push
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
      voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    @objc(pushRegistry:didInvalidatePushTokenForType:) func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

     // Handle incoming pushes
    @objc(pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:) func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("payload \(payload.dictionaryPayload)")
        guard type == .voIP else { return }
        
        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let nameCaller = payload.dictionaryPayload["nameCaller"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
        
        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
        //set more data
        data.extra = ["user": "abc@123", "platform": "ios"]
        //data.iconName = ...
        //data.....
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
        
        //Make sure call completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

}
