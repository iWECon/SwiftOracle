

import cocilib







class BindVar: StringLiteralConvertible, IntegerLiteralConvertible, BooleanLiteralConvertible, FloatLiteralConvertible  {
    let bind: (COpaquePointer, String) -> Void
    private let dealoc: () -> Void
    deinit{
        dealoc()
    }
    init( fromInt value: Int) {
        let v = Int32(value)
        let p = UnsafeMutablePointer<Int32>.alloc(1)
        p.initialize(v)
        bind = { st, name in OCI_BindInt(st, name, p) }
        dealoc = {
            p.destroy()
            p.dealloc(1)
        }
    }
    init (fromString value: String) {
        let v = Array(value.nulTerminatedUTF8).map( {Int8($0) })
        let p = UnsafeMutablePointer<Int8>.alloc(v.count)
        p.initializeFrom(v)
        bind = {st, name in OCI_BindString(st, name, p, 0)}
        dealoc = {
            p.destroy()
            p.dealloc(v.count)
        }
    }
    init (fromBool value: Bool) {
        let p = UnsafeMutablePointer<Int32>.alloc(1)
        p.initialize(Int32((value) ? 1: 0))
        bind = {st, name in OCI_BindBoolean(st, name, p)}
        dealoc = {
            p.destroy()
            p.dealloc(1)
        }
    }
    
    init (fromDouble value: Double) {
        let p = UnsafeMutablePointer<Double>.alloc(1)
        p.initialize(value)
        bind = {st, name in OCI_BindDouble(st, name, p)}
        dealoc = {
            p.destroy()
            p.dealloc(1)
        }
    }

    required convenience init(stringLiteral value: String) {
        self.init(fromString: value)
    }
    required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(fromString: value)
    }
    required convenience init(unicodeScalarLiteral value: String) {
        self.init(fromString: value)
    }
    required convenience init(integerLiteral value: Int){
        self.init(fromInt: value)
    }
    required convenience init(booleanLiteral value: Bool) {
        self.init(fromBool: value)
    }
    
    required convenience init(floatLiteral value: Double) {
        self.init(fromDouble: value)
    }
}

