
import cocilib

@_exported import SQL


enum OracleError: ErrorType {
    case NotConnected
}


public struct ConnectionInfo {
    let service_name: String, user:String, pwd: String
}

class Connection {
    // associatedtype Error: ErrorType
    
    var cn: COpaquePointer? = nil
    let conn_info: ConnectionInfo
    required init(service_name: String, user:String, pwd: String) {
        conn_info = ConnectionInfo(service_name: service_name, user: user, pwd: pwd)
        OCI_Initialize(nil, nil, UInt32(OCI_ENV_DEFAULT)); //should be once per app
    }
    required convenience init (service: OracleService, user: String, pwd: String){
        self.init(service_name: service.string, user: user, pwd: pwd)
    }
    func close() {
        guard var cn = cn else {
            return
        }
        OCI_ConnectionFree(cn)
        cn = nil
    }
    func open() throws {
        cn = OCI_ConnectionCreate(conn_info.service_name, conn_info.user, conn_info.pwd, UInt32(OCI_SESSION_DEFAULT));
    }
    func execute(statement: String) throws -> Result  {
        guard let cn = cn else {
            throw OracleError.NotConnected
        }
        
        let st = OCI_StatementCreate(cn);
        OCI_ExecuteStmt(st, statement);
        return Result(st)
        
    }
    var connected: Bool {
        guard let cn = cn else {
            return false
        }
        return OCI_IsConnected(cn) == 1
    }
    deinit {
        close()
        OCI_Cleanup()  //should be once per app
    }
    
}


