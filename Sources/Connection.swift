
import cocilib
import String
//@_exported import SQL


struct DatabaseError: CustomStringConvertible {
    let error: OpaquePointer
    var text: String {
        return String(validatingUTF8: OCI_ErrorGetString(error))!
    }
    var type: Int {
        return Int(OCI_ErrorGetType(error))
    }
    var code: Int {
        return Int(OCI_ErrorGetOCICode(error))
    }
    var statement: String {
        let st = OCI_ErrorGetStatement(error)
        let text = OCI_GetSql(st)
        return String(validatingUTF8: text)!
    }
    init(_ error: OpaquePointer) {
        self.error = error
    }
    var description: String {
        return "text: \(text.trim()),\n\tstatement: \(statement)"
    }
    
}

enum DatabaseErrors: ErrorProtocol {
    case NotConnected, NotExecuted
}

func error_callback(error: OpaquePointer) {
    print(DatabaseError(error))
}

public struct ConnectionInfo {
    let service_name: String, user:String, pwd: String
}



public struct OracleService {
    var raw_str: String?, host:String?, port:String?, service:String?
    public init(from_string raw_str: String){
        self.raw_str = raw_str
    }
    public init(host: String, port: String, service: String) {
        self.host = host; self.port = port; self.service = service
    }
    
    var string: String {
        if let raw_str = raw_str {
            return raw_str
        }
        if let host = host, port = port, service = service  {
            return "\(host):\(port)/\(service)"
        }
        return ""
    }
}



public class Connection {
    // associatedtype Error: ErrorType
    
    private var connection: OpaquePointer? = nil
    
    
    let conn_info: ConnectionInfo
    
    public required init(service: OracleService, user:String, pwd: String) {
        conn_info = ConnectionInfo(service_name: service.string, user: user, pwd: pwd)
        OCI_Initialize({error_callback($0)}, nil, UInt32(OCI_ENV_DEFAULT)); //should be once per app
    }
    
    func close() {
        guard var connection = connection else {
            return
        }
        OCI_ConnectionFree(connection)
        connection = nil
    }
    public func open() throws {
        connection = OCI_ConnectionCreate(conn_info.service_name, conn_info.user, conn_info.pwd, UInt32(OCI_SESSION_DEFAULT));
    }
    public func cursor() throws -> Cursor {
        guard let connection = connection else {
            throw DatabaseErrors.NotConnected
        }
        return Cursor(connection: connection)
    }
    public var connected: Bool {
        guard let connection = connection else {
            return false
        }
        return OCI_IsConnected(connection) == 1
    }
    public var autocommit: Bool {
        set(newValue) {
            OCI_SetAutoCommit(connection!, (newValue) ? 1 : 0)
        }
        get {
            return OCI_GetAutoCommit(connection!) == 1
        }
    }
    func transaction_create() throws {
        guard let connection = connection else {
            throw DatabaseErrors.NotExecuted
        }
//        OCI_TransactionCreate(connection, nil, nil, nil)
    }
    deinit {
        close()
        OCI_Cleanup()  //should be once per app
    }
    
}


