import cocilib




//OCI_CDT_NUMERIC
public enum DataTypes {
    case number(scale: Int), int, timestamp, bool, string, invalid
    init(col: OpaquePointer){
        let type = OCI_ColumnGetType(col)
        switch Int32(type) {
        case OCI_CDT_NUMERIC:
            let scale = OCI_ColumnGetScale(col)
            self = .number(scale: Int(scale))
        case OCI_CDT_TEXT:
            self = .string
        case OCI_CDT_TIMESTAMP:
            self = .timestamp
        case OCI_CDT_BOOLEAN:
            self = .bool
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




open class Cursor : Sequence, IteratorProtocol {
    
    open var resultPointer: OpaquePointer?
    fileprivate var statementPointer: OpaquePointer
    fileprivate let connection: OpaquePointer
    
    fileprivate var _columns: [Column]?
    
    fileprivate var binded_vars: [BindVar] = []
    
    public init(connection: OpaquePointer) {
        self.connection = connection
        statementPointer = OCI_StatementCreate(connection)
    }
    
    deinit {
        clear()
    }
    open func clear() {
        OCI_StatementFree(statementPointer)
    }
    fileprivate func get_columns() -> [Column] {
        guard let resultPointer=self.resultPointer else {
            return []
        }
        var result: [Column] = []
        let colsCount = OCI_GetColumnCount(resultPointer)
        for i in 1...colsCount {
            let col = OCI_GetColumn(resultPointer, i)
            let name_p =  OCI_ColumnGetName(col)
            let name =  String(validatingUTF8: name_p!)
            
            let type = DataTypes(col: col!)
            result.append(
                Column(name: name!, type: type
                )
            )
        }
        return result
    }
    open var affected: Int {
        return Int(OCI_GetAffectedRows(statementPointer))
    }
    
    func reset() {
        _columns = nil
        binded_vars = []
        if resultPointer != nil{
            OCI_ReleaseResultsets(statementPointer)
        }
        resultPointer = nil
    }
    
    open func bind(_ name: String, bindVar: BindVar) {
        bindVar.bind(statementPointer, name)
        binded_vars.append(bindVar)
    }
    
    open func register(_ name: String, type: DataTypes) {
        switch type {
        case .int:
            OCI_RegisterInt(statementPointer, name)
        default:
            assert(1==0)
        }
    }
    
    open func execute(_ statement: String, params: [String: BindVar]=[:], register: [String: DataTypes]=[:]) throws {
        reset()
        let prepared = OCI_Prepare(statementPointer, statement)
        assert(prepared == 1)
        for (name, bindVar) in params {
            bind(name, bindVar: bindVar)
        }
        for (name, type) in register {
            self.register(name, type: type)
        }
        let executed = OCI_Execute(statementPointer);
        if executed != 1{
            throw DatabaseErrors.notExecuted
        }
        resultPointer = OCI_GetResultset(statementPointer)
    }
    open func fetchone() -> Row? {
        guard let resultPointer=resultPointer else {
            return nil
        }
        let fetched = OCI_FetchNext(resultPointer)
        if fetched == 0 {
            return nil
        }
        return Row(resultPointer: resultPointer, columns: self.columns)
        
    }
    open func next() -> Row? {
        return fetchone()
    }
    
    open var count: Int {
        guard let resultPointer=self.resultPointer else {
            return 0
        }
        return Int(OCI_GetRowCount(resultPointer))
    }
    
    open var columns: [Column] {
        if _columns == nil {
            _columns = get_columns()
        }
        return _columns!
    }
}



