
import cocilib


open class Field {
    fileprivate let resultPointer: OpaquePointer
    fileprivate let index: UInt32
    let type: DataTypes
    init(resultPointer: OpaquePointer, index: Int, type: DataTypes){
        self.resultPointer = resultPointer
        self.index = UInt32(index+1)
        self.type = type
    }
    open var isNull: Bool {
        return OCI_IsNull(resultPointer, index) == 1
    }
    open var string: String? {
        if let s = OCI_GetString(resultPointer, index) {
            return String(validatingUTF8: s)
        }
        return nil
    }
    open var int: Int {
        return Int(OCI_GetInt(resultPointer, index))
    }
    open var double: Double {
        return OCI_GetDouble(resultPointer, index)
    }
    open var datetime: String? {
        var year: Int32 = -1,
            month: Int32 = -1,
            day: Int32 = -1,
            hour: Int32 = -1,
            min: Int32 = -1,
            sec: Int32 = -1
        
        if let datePointer = OCI_GetDate(resultPointer, index),
           (OCI_DateGetDateTime(datePointer, &year, &month, &day, &hour, &min, &sec) != 0)
        {
            return "\(year)-\(month)-\(day) \(hour):\(min):\(sec)"
        }
        return nil
    }
    open var value: Any? {
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
        case .datetime:
            return self.datetime
        default:
            assert(0 == 1, "bad value \(type)")
            return "asd" as AnyObject
        }
    }
}


open class Row {
    fileprivate let resultPointer: OpaquePointer
    let columns: [Column]
    //todo invalidate row
    init(resultPointer: OpaquePointer, columns: [Column]){
        self.resultPointer = resultPointer
        self.columns = columns
    }
    open subscript (name: String) -> Field? {
        let maybeIndex = columns.firstIndex(where: {$0.name==name})
        guard let index = maybeIndex else {
            return nil
        }
        return Field(resultPointer: resultPointer, index: index, type: columns[index].type)
    }
    open subscript (index: Int) -> Field? {
        guard index >= 0 && index < columns.count else {
            return nil
        }
        let c = columns[index]
        return Field(resultPointer: resultPointer, index: index, type: c.type)
    }
    open lazy var dict: [String : Any?] = {
        var result: [String : Any?]  = [:]
        for (index, column) in self.columns.enumerated() {
            result[column.name] = Field(resultPointer: self.resultPointer, index: index, type: column.type).value
        }
        return result
    }()
    open lazy var list: [Any?] = {
        var result: [Any?]  = []
        for (index, column) in self.columns.enumerated() {
            result.append(Field(resultPointer: self.resultPointer, index: index, type: column.type).value)
        }
        return result
    }()
}
