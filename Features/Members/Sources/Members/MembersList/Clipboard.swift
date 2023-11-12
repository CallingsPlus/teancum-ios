#if os(macOS)
import AppKit
#else
import UIKit
#endif

class Clipboard {

    static func getClipboardString() -> String? {
        #if os(macOS)
        // Use NSPasteboard for Mac Catalyst
        return NSPasteboard.general.string(forType: .string)
        #else
        // Use UIPasteboard for iOS
        return UIPasteboard.general.string
        #endif
    }

    static func setClipboardString(_ string: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #else
        UIPasteboard.general.string = string
        #endif
    }
    
    static var pasteNotification: Notification.Name {
        #if os(macOS)
        // Mac Catalyst uses NSPasteboard
        return NSNotification.Name("NSPasteboardDidChangeNotification")
        #else
        // iOS uses UIPasteboard
        return UIPasteboard.changedNotification
        #endif
    }
}
