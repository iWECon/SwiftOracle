
import cocilib


class Field {
    private let resultPointer: COpaquePointer
    private let index: UInt32
    let type: DataTypes
    init(resultPointer: COpaquePointer, index: Int, type: DataTypes){
        self.resultPointer = resultPointer
        self.index = UInt32(index+1)
        self.type = type
    }
    var isNull: Bool {
        return OCI_IsNull(resultPointer, index) == 1
    }
    var string: String {
        let s = OCI_GetString(resultPointer, index)
        return String.fromCString(s)!
    }
    var int: Int {
        return Int(OCI_GetInt(resultPointer, index))
    }
    var double: Double {
        return OCI_GetDouble(resultPointer, index)
    }
    var value: Any? {
        if self.isNull{
            return nil as Any?
        }
        switch type {
        case .string, .timestamp:
            return self.string
        case let .number(scale):
            if scale==0 {
                return self.int
            }
            else{
                return self.double
            }
        default:
            assert(0==1,"bad value \(type)")
            return "asd" as! AnyObject
        }
    }
}


public class Row {
    private let resultPointer: COpaquePointer
    let columns: [Column]
    //todo invalidate row
    init(resultPointer: COpaquePointer, columns: [Column]){
        self.resultPointer = resultPointer
        self.columns = columns
    }
    subscript (name: String) -> Field? {
        let maybeIndex = columns.indexOf({$0.name==name})
        guard let index = maybeIndex else {
            return nil
        }
        return Field(resultPointer: resultPointer, index: index, type: columns[index].type)
    }
    subscript (index: Int) -> Field? {
        guard index >= 0 && index < columns.count else {
            return nil
        }
        let c = columns[index]
        return Field(resultPointer: resultPointer, index: index, type: c.type)
    }
    lazy var dict: [String : Any?] = {
        var result: [String : Any?]  = [:]
        for (index, column) in self.columns.enumerate() {
            result[column.name] = Field(resultPointer: self.resultPointer, index: index, type: column.type).value
        }
        return result
    }()
    lazy var list: [Any?] = {
        var result: [Any?]  = []
        for (index, column) in self.columns.enumerate() {
            result.append(Field(resultPointer: self.resultPointer, index: index, type: column.type).value)
        }
        return result
    }()
}