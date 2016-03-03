


public struct Field: SQL.Field {
    public let name: String
    public let type: DataTypes
    init(name: String, type: DataTypes) {
        self.name = name
        self.type = type
   }
}
