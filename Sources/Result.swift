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


//enum DataTypes: Int32 {
//    case num = OCI_CDT_NUMERIC,
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


public class Result : SequenceType, GeneratorType {
    
    public let resultPointer: COpaquePointer
    private let statementPointer: COpaquePointer
    
    
    
    public init(_ statementPointer: COpaquePointer) {
        self.statementPointer = statementPointer
//        OCI_SetFetchSize(statementPointer, 1)
        self.resultPointer = OCI_GetResultset(statementPointer)
    }
    
    deinit {
        clear()
    }
    public func clear() {
        OCI_StatementFree(statementPointer)
        
    }
    
    func getValue(type: UInt32, index: UInt32) -> AnyObject {
        switch Int32(type) {
        case OCI_CDT_TEXT, OCI_CDT_TIMESTAMP:
            let s = OCI_GetString(resultPointer, index)
            return String.fromCString(s)!
        case OCI_CDT_NUMERIC:
            return OCI_GetDouble(resultPointer, index)
//        case :
//            return Int(OCI_GetInt(resultPointer, index))
        default:
            assert(0==1,"bad value\(type)")
        }
    }
    
    public func next() -> [String: AnyObject]? {
        let fetched = OCI_FetchNext(resultPointer)
        if fetched == 0 {
            return nil
        }
//        assert(fetched==1)
        return get_result()
    }
    func get_result() -> [String: AnyObject] {
        var result: [String: AnyObject] = [:]
        
        for (fieldIndex, field) in fields.enumerate() {
            let index = UInt32(fieldIndex+1)
            if OCI_IsNull(resultPointer, index) == 1 {
                result[field.name] = nil
            } else {
                result[field.name] = getValue(field.type, index: index)
                
            }
        }
        
        return result

    }
    
    public var count: Int {
        return Int(OCI_GetRowCount(resultPointer))
    }
    
    public lazy var fields: [Field] = {
        var result: [Field] = []
        let colsCount = OCI_GetColumnCount(self.resultPointer)
        print("colsCount=\(colsCount)")
        for i in 1...colsCount {
            let col = OCI_GetColumn(self.resultPointer, i)
//            print(col)
            let name_p =  OCI_ColumnGetName(col)
            let name =  String.fromCString(name_p)
        
            
            result.append(
                Field(name: name!, type: OCI_ColumnGetType(col)
                )
            )
        }
        print(result)
        return result
        // return result
    }()
}




