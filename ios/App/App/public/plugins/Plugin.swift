import Foundation
import Capacitor
import AppTrackingTransparency

@objc(AppTrackingTransparencyPlugin)
public class AppTrackingTransparencyPlugin: CAPPlugin {
    @objc func requestPermission(_ call: CAPPluginCall) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                var result = ""
                switch status {
                case .authorized:
                    result = "authorized"
                case .denied:
                    result = "denied"
                case .notDetermined:
                    result = "notDetermined"
                case .restricted:
                    result = "restricted"
                @unknown default:
                    result = "unknown"
                }
                call.resolve([
                    "status": result
                ])
            }
        } else {
            call.resolve([
                "status": "unavailable"
            ])
        }
    }
}
