import cocilib

import Foundation


class FieldValue {
    
}

class ResultDict {
    let fields: [Field]
    init(fields: [Field]){
        self.fields = fields
    }
    //    public subscript(name: String) -> FieldValue? {
    
    //    }
}

//OCI_CDT_NUMERIC
public enum DataTypes {
    case number(scale: Int), timestamp, string, invalid
    init(col: COpaquePointer){
        let type = OCI_ColumnGetType(col)
        switch Int32(type) {
        case OCI_CDT_NUMERIC:
            let scale = OCI_ColumnGetScale(col)
            self = .number(scale: Int(scale))
        case OCI_CDT_TEXT:
            self = .string
        case OCI_CDT_TIMESTAMP:
            self = .timestamp
        default:
            self = .invalid
            assert(1==0)
        }
    }
}
//    datetime = OCI_CDT_DATETIME,
//    text = OCI_CDT_TEXT,
//    long = OCI_CDT_LONG,
//    cursor = OCI_CDT_CURSOR,
//    lob = OCI_CDT_LOB,
//    file =  OCI_CDT_FILE,
//    timestamp = OCI_CDT_TIMESTAMP,
//    interval = OCI_CDT_INTERVAL,
//    raw = OCI_CDT_RAW,
//    object = OCI_CDT_OBJECT,
//    collection = OCI_CDT_COLLECTION,
//    ref = OCI_CDT_REF,
//    bool = OCI_CDT_BOOLEAN
//}


//case Number(precise)


public class Cursor : SequenceType, GeneratorType {
    public typealias RowType = [String: AnyObject?]
    
    public var resultPointer: COpaquePointer?
    private var statementPointer: COpaquePointer
    private let connection: COpaquePointer
    
    private var _fields: [Field]?
    
    public init(connection: COpaquePointer) {
        self.connection = connection
        statementPointer = OCI_StatementCreate(connection)
    }
    
    deinit {
        clear()
    }
    public func clear() {
        OCI_StatementFree(statementPointer)
    }
    private func get_fields() -> [Field] {
        guard let resultPointer=self.resultPointer else {
            return []
        }
        var result: [Field] = []
        let colsCount = OCI_GetColumnCount(resultPointer)
        //        print("colsCount=\(colsCount)")
        for i in 1...colsCount {
            let col = OCI_GetColumn(resultPointer, i)
            //            print(col)
            let name_p =  OCI_ColumnGetName(col)
            let name =  String.fromCString(name_p)
            
            let type = DataTypes(col: col)
            result.append(
                Field(name: name!, type: type
                )
            )
        }
        //        print(result)
        return result
        
    }
    var affected: Int {
        return Int(OCI_GetAffectedRows(statementPointer))
    }
    func getValue(type: DataTypes, index: UInt32) throws -> AnyObject {
        guard let resultPointer=resultPointer else {
            throw OracleError.NotExecuted
        }
        switch type {
        case .string, .timestamp:
            let s = OCI_GetString(resultPointer, index)
            return String.fromCString(s)!
            
        case let .number(scale):
            if scale==0 {
                return Int(OCI_GetInt(resultPointer, index))
            }
            else{
                return OCI_GetDouble(resultPointer, index)
            }
        default:
            assert(0==1,"bad value \(type)")
            return "asd"
        }
        
    }
    
    func bind_type(name: String, val: AnyObject?) {
        switch val {
        case let val as Int:
            let v = Int32(val)
            let p = UnsafeMutablePointer<Int32>.alloc(1)
            p.initialize(v)
            OCI_BindInt(statementPointer, name, p)
        //            p.dealloc(1) //will be not correct
        case let val as String:
            let v = Array(val.nulTerminatedUTF8).map( {Int8($0) })
            let p = UnsafeMutablePointer<Int8>.alloc(v.count)
            p.initializeFrom(v)
            OCI_BindString(statementPointer, name, p, 0)
            
        //            p.destroy()
        case let val as Bool:
            let p = UnsafeMutablePointer<Int32>.alloc(1)
            p.memory = Int32((val) ? 1: 0)
            OCI_BindBoolean(statementPointer, name, p)
        default:
            assert(1==0)
        }
    }
    
    
    func execute(statement: String, params: [String: AnyObject?]=[:]) throws {
        //        guard let connection = cn else {
        //            throw OracleError.NotConnected
        //        }
        _fields = nil
        if resultPointer != nil{
            OCI_ReleaseResultsets(statementPointer)
        }
        
        let prepared = OCI_Prepare(statementPointer, statement)
        assert(prepared == 1)
        for (name, val) in params {
            //            var v = Int32(val as! Int)
            //            OCI_BindInt(st, name, &v)
            bind_type(name, val: val)
        }
        let executed = OCI_Execute(statementPointer);
        assert(executed==1)
        resultPointer = OCI_GetResultset(statementPointer)
    }
    public func fetchone() -> RowType? {
        guard let resultPointer=resultPointer else {
            return nil
        }
        let fetched = OCI_FetchNext(resultPointer)
        if fetched == 0 {
            return nil
        }
        return try? get_result()
        
    }
    public func next() -> RowType? {
        return fetchone()
    }
    func get_result() throws -> RowType {
        guard let resultPointer=resultPointer else {
            throw OracleError.NotExecuted
        }
        var result: RowType = [:]
        
        for (fieldIndex, field) in fields.enumerate() {
            let index = UInt32(fieldIndex+1)
            if OCI_IsNull(resultPointer, index) == 1 {
                result[field.name] = nil as AnyObject?
                //                result.append(nil as AnyObject?)
            } else {
                //                result.append(try getValue(field.type, index: index))
                result[field.name] = try getValue(field.type, index: index)
                
            }
        }
        
        return result
        
    }
    
    public var count: Int {
        guard let resultPointer=self.resultPointer else {
            return 0
        }
        return Int(OCI_GetRowCount(resultPointer))
    }
    
    public var fields: [Field] {
        if _fields == nil {
            _fields = get_fields()
        }
        return _fields!
    }
}



