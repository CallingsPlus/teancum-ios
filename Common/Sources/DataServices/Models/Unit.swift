public protocol Unit {
    var id: String? { get }
    var name: String? { get }
}

#if DEBUG
public struct MockUnit: Unit {
    public var id: String?
    public var name: String?
    
    public init(id: String? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }
}
#endif
