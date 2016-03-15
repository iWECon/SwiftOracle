

import cocilib







public class BindVar: StringLiteralConvertible, IntegerLiteralConvertible, BooleanLiteralConvertible, FloatLiteralConvertible  {
    let bind: (COpaquePointer, String) -> Void
    var value: Any
    public init(_ value: Int) {
        var v = Int32(value)
        bind = { st, name in OCI_BindInt(st, name, &v) }
        self.value = v
        
    }
    public init (_ value: String) {
        var v = Array(value.nulTerminatedUTF8).map( {Int8(bitPattern: $0) })
        bind = {st, name in OCI_BindString(st, name, &v, 0)}
        self.value = v
    }
    public init (_ value: Bool) {
        var v = Int32((value) ? 1: 0)
        bind = {st, name in OCI_BindBoolean(st, name, &v)}
        self.value = v
    }
    
    public init (_ value: Double) {
        var v = value
        bind = {st, name in OCI_BindDouble(st, name, &v)}
        self.value = v
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(value)
    }
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init( value)
    }
    public required convenience init(integerLiteral value: Int){
        self.init(value)
    }
    public required convenience init(booleanLiteral value: Bool) {
        self.init(value)
    }
    public required convenience init(floatLiteral value: Double) {
        self.init(value)
    }
}

