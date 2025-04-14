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
        guard type == .voIP else {
            print("Received non-VoIP push")
            return
        }

         // 1. Extract call SID, caller ID, etc. from payload
        if let callSID = payload.userInfo["callSID"] as? String,
           let callerID = payload.userInfo["callerID"] as? String {
            // 2. Create a CXCallController
            let callController = CXCallController()
            // 3. Report the incoming call to CallKit
            let reportOptions = CXCallUpdateOptions()
            reportOptions.includeCallInfo = true // Optional: Include call details

            let update = CXCallUpdate(handle: CXHandle(type: .phoneNumber, value: callerID),
                                     connection: nil,
                                     callInfo: CXCallInfo(),
                                     localizedCallInfo: "Incoming call from \(callerID)",
                                     options: reportOptions)
            // 4. Report the call
            let reportCallRequest = CXReportCallRequest(callUUID: UUID(), update: update)
            callController.reportCall(with: reportCallRequest) { error in
                if let error = error {
                    print("Error reporting call: \(error)")
                } else {
                    print("Call reported to CallKit successfully")
                }
            }
        }
    }

        // Ensure completion is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

}
