import Foundation

public struct Location: Encodable {
    public let module: String
    public let file: String
    public let line: Int
    public let column: Int
    
    init(fileID: String, line: Int, column: Int) {
        // Convert ModuleName/FileName.fileextension to module and file
        let split = (fileID as NSString).components(separatedBy: "/")
        module = split.count == 2 ? (split.first ?? "unknown") : "unknown"
        file = split.last ?? "unknown"
        self.line = line
        self.column = column
    }
}
