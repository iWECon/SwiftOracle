import cocilib

import Foundation

public class Result {
    
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
    
    
    public subscript(position: Int) -> String {
        
        var result: [String: Data?] = [:]
    

//        let fetched = OCI_FetchSeek(resultPointer, UInt32(OCI_SFD_ABSOLUTE), Int32(position+1))
        OCI_FetchNext(resultPointer)
        
        
        
        
        print(OCI_GetInt(resultPointer, 1))
        
         for (fieldIndex, field) in fields.enumerate() {
            print(field.name)
            let index = UInt32(fieldIndex+1)
            if OCI_IsNull(resultPointer, index)==1 {
                result[field.name] = nil
            } else {
                let len = OCI_GetDataLength(resultPointer, index )
//                print(len)
                var buffer = [Int8](count: Int(len), repeatedValue: 0)
//                let bytesCopied = OCI_GetRaw(resultPointer, index, &buffer, len)
                
//                assert(bytesCopied != UInt32(0))
                let s = OCI_GetString(resultPointer, index)
                print(String.fromCString(s))
//                print(buffer)
//                print(String.fromCString(Array(buffer)))
//                print(String.fromCString(buffer))
//                result[field.name] = Data(
//                    pointer: &buffer,
//                    length: len
//                )
                
                
            }
        }
        // let val = row[fieldIndex]
        // let length = Int(lengths[fieldIndex])
        
        // var buffer = [UInt8](count: length, repeatedValue: 0)
        
        // memcpy(&buffer, val, length)
//        Data(
        // result[field.name] = Value(data: Data(uBytes: buffer))
        // }
        return "asd"
        // return Row(dataByFieldName: result)
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
                Field(name: name!)
            )
        }
        return result
        // return result
    }()
}




