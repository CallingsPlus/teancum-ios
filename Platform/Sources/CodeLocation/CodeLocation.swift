public struct CodeLocation: Encodable {
    public let domain: String
    public let module: String
    public let file: String
    public let function: String
    public let line: Int
    public let column: Int
    
    package init(domain: CodeDomain, fileID: String, function: String, line: Int, column: Int) {
        let (file, module) = Self.split(fileID: fileID)
        self.domain = domain.description
        self.module = module
        self.file = file
        self.function = function
        self.line = line
        self.column = column
    }
    
    /// Converts ModuleName/FileName.extension to module and file
    static func split(fileID: String) -> (fileName: String, module: String) {
        let split = fileID.split(separator: "/")
        let module = split.count == 2 ? (String(split.first ?? "unknown")) : "unknown"
        let file = String(split.last ?? "unknown")
        return (file, module)
    }
}

// MARK: CodeDomain

public protocol CodeDomain: CustomStringConvertible, Encodable { }

extension String: CodeDomain { }

enum CodeDomainCodingKeys: CodingKey {
    case logDomain
}

extension CodeDomain {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
