


public struct Field: SQL.Field {
    public var name: String
    public var type: UInt32
    init(name: String, type: UInt32) {
        self.name = name
        self.type = type
   }
}