import Cocoa
import AppKit
import ShareLinkActions

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {}
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager
            .shared()
            .setEventHandler(
                self,
                andSelector: #selector(handleURL(event:reply:)),
                forEventClass: AEEventClass(kInternetEventClass),
                andEventID: AEEventID(kAEGetURL)
            )
    }


    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func handleURL(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            guard let components = URLComponents(string: urlString) else { return }
            guard let queryItems = components.queryItems else { return }
            
            let parameters = queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
            let path = "/\(components.host ?? "")" + components.path
            
            let action = parameters["action"].map { ShareLinkAction(rawValue: $0) ?? .open } ?? .open
            switch action {
            case .reveal:
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            case .open:
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            }
        }
    }

}
