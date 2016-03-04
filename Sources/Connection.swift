
import cocilib

@_exported import SQL


enum DatabaseError: ErrorType {
    case NotConnected, NotExecuted
}


public struct ConnectionInfo {
    let service_name: String, user:String, pwd: String
}

func error_handler (err: COpaquePointer) {
    print(String.fromCString(OCI_ErrorGetString(err)))
}

class Connection {
    // associatedtype Error: ErrorType
    
    private var connection: COpaquePointer? = nil
    
    let conn_info: ConnectionInfo
    required init(service_name: String, user:String, pwd: String) {
        conn_info = ConnectionInfo(service_name: service_name, user: user, pwd: pwd)
        OCI_Initialize({error_handler($0)}, nil, UInt32(OCI_ENV_DEFAULT)); //should be once per app
    }
    required convenience init (service: OracleService, user: String, pwd: String){
        self.init(service_name: service.string, user: user, pwd: pwd)
    }
    
    
    
    func get_last_error(){
        let err = OCI_GetLastError()
        //        if err == 0 {
        print(String.fromCString(OCI_ErrorGetString(err))!)
        //        }
    }
    
    func close() {
        guard var connection = connection else {
            return
        }
        OCI_ConnectionFree(connection)
        connection = nil
    }
    func open() throws {
        connection = OCI_ConnectionCreate(conn_info.service_name, conn_info.user, conn_info.pwd, UInt32(OCI_SESSION_DEFAULT));
    }
    func cursor() throws -> Cursor {
        guard let connection = connection else {
            throw DatabaseError.NotConnected
        }
        return Cursor(connection: connection)
    }
    var connected: Bool {
        guard let connection = connection else {
            return false
        }
        return OCI_IsConnected(connection) == 1
    }
    var autocommit: Bool {
        set(newValue) {
            OCI_SetAutoCommit(connection!, (newValue) ? 1 : 0)
        }
        get {
            return OCI_GetAutoCommit(connection!) == 1
        }
    }
    func transaction_create() throws {
        guard let connection = connection else {
            throw DatabaseError.NotExecuted
        }
//        OCI_TransactionCreate(connection, nil, nil, nil)
    }
    deinit {
        close()
        OCI_Cleanup()  //should be once per app
    }
    
}


