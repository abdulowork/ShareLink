import Cocoa
import AppKit
import ShareLinkActions
import SwiftUI
import MenuUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    private let state = LogsState()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentViewSwiftUI = LogsView(logsState: state)
        let contentView = NSHostingView(rootView: contentViewSwiftUI)
        contentView.frame = NSRect(x: 0, y: 0, width: 400, height: 400)
        
        let iconSwiftUI = IconView()
        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 22, height: 22)
        
        let menuItem = NSMenuItem()
        menuItem.view = contentView
        let menu = NSMenu()
        menu.addItem(menuItem)
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = menu
        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
        self.statusItem = statusItem
    }
    
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
        state.logs.append(Log(value: "Event \(event)"))
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            guard let components = URLComponents(string: urlString) else {
                state.logs.append(Log(value: "Couldn't create components"))
                return
            }
            guard let queryItems = components.queryItems else {
                state.logs.append(Log(value: "Couldn't query items"))
                return
            }
            
            let parameters = queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
            let path = "/\(components.host ?? "")" + components.path
            
            let action = parameters["action"].map { ShareLinkAction(rawValue: $0) ?? .open } ?? .open
            state.logs.append(
                Log(value: 
                    """
                    Openning path: "\(path)"
                    With action: "\(action)"
                    """
                )
            )
            
            switch action {
            case .reveal:
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            case .open:
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            }
        }
    }
}
