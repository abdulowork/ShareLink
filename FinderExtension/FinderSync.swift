import Cocoa
import FinderSync
import SearchForMount
import ShareLinkActions

class FinderSync: FIFinderSync {

    override init() {
        super.init()
        
        let controller = FIFinderSyncController.default()
        controller.directoryURLs = [
            URL(fileURLWithPath: "/"),
        ]
        
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: .skipHiddenVolumes
        ) {
            mountedVolumes.filter(\.isSmbfs).forEach {
                controller.directoryURLs.insert($0)
            }
        }
        
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) {
            (notification) in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                controller.directoryURLs.insert(volumeURL)
            }
        }
        notificationCenter.addObserver(forName: NSWorkspace.didUnmountNotification, object: nil, queue: .main) {
            (notification) in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                controller.directoryURLs.remove(volumeURL)
            }
        }
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "ShareLink")
        menu.addItem(
            withTitle: "Copy ShareLink to file",
            action: #selector(writeOpenShareLinkToPasteboard(_:)),
            keyEquivalent: "b"
        ).keyEquivalentModifierMask = .command
        menu.addItem(
            withTitle: "Copy ShareLink to reveal file in Finder",
            action: #selector(writeRevealShareLinkToPasteboard(_:)),
            keyEquivalent: "n"
        ).keyEquivalentModifierMask = .command
        menu.addItem(
            withTitle: "Copy smb:// link",
            action: #selector(writeSmbLinkToPasteboard(_:)),
            keyEquivalent: "m"
        ).keyEquivalentModifierMask = .command
        return menu
    }
    
    @IBAction func writeOpenShareLinkToPasteboard(_ sender: AnyObject?) {
        writeShareLinkToPasteboard(action: .open)
    }
    
    @IBAction func writeRevealShareLinkToPasteboard(_ sender: AnyObject?) {
        writeShareLinkToPasteboard(action: .reveal)
    }
    
    private func writeShareLinkToPasteboard(action: ShareLinkAction) {
        setPasteboardFromSelectedItems { items in
            items.map(\.absoluteURL).map { $0.shareLink(action: action) }
        }
    }

    @IBAction func writeSmbLinkToPasteboard(_ sender: AnyObject?) {
        setPasteboardFromSelectedItems { items in
            items.compactMap { item -> String? in
                let fsPath = item.path(percentEncoded: false)
                guard let pathInfo = PathInfo(path: fsPath), pathInfo.isSmbfs else {
                    return nil
                }
                let urlPath = item.path(percentEncoded: true)
                guard urlPath.hasPrefix(pathInfo.mountPath) else {
                    return nil
                }
                return "smb:" + pathInfo.mountUrl + urlPath[urlPath.index(urlPath.startIndex, offsetBy: pathInfo.mountPath.count)...]
            }
        }
    }
    
    private func setPasteboardFromSelectedItems(
        pasteboardStringFromItems: ([URL]) -> [String]
    ) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            return
        }
        NSPasteboard.general.clearContents()

        let links = pasteboardStringFromItems(items)
        
        NSPasteboard.general.setString(
            links.joined(separator: "\n"),
            forType: .string
        )
        NSPasteboard.general.setData(
            Data("<html><body>\(joinATags(links: links))</body></html>".utf8),
            forType: .html
        )
    }
    
    private func joinATags(links: [String]) -> String {
        links.map { link in
            "<a href=\"\(link)\">\(link)</a>"
        }.joined(separator: "<span style=\"white-space: pre-line\">\n</span>")
    }

}

extension URL {
    func shareLink(action: ShareLinkAction) -> String { "sl:/\(path(percentEncoded: true))?action=\(action.rawValue)" }
    
    var isSmbfs: Bool { PathInfo(path: path())?.isSmbfs == true }
}
extension PathInfo {
    var isSmbfs: Bool { mountType == "smbfs" }
}

