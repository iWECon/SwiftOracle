
import cocilib

@_exported import SQL


enum OracleError: ErrorType {
    case NotConnected
}


public struct ConnectionInfo {
    let service_name: String, user:String, pwd: String
}

func error_handler (err: COpaquePointer) {
    print(String.fromCString(OCI_ErrorGetString(err)))
}

class Connection {
    // associatedtype Error: ErrorType
    
    private var cn: COpaquePointer? = nil
    
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
        print(String.fromCString(OCI_ErrorGetString(err)))
        //        }
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
    
    func bind_type(st: COpaquePointer, name: String, val: AnyObject) {
        
        switch val {
        case let val as Int:
            let v = Int32(val)
            let p = UnsafeMutablePointer<Int32>.alloc(1)
            p.memory = v
            OCI_BindInt(st, name, p)
//            p.dealloc(1) //will be not correct
        case let val as String:
            //            var array: [UInt8] = Array(val.utf8)
            //            array.append(0)
            //            let p = UnsafeMutablePointer<otext>(array)
            val.withCString({OCI_BindString(st, name, UnsafeMutablePointer($0), UInt32(val.characters.count))})
            //            p.destroy()
        case let val as Bool:
            let p = UnsafeMutablePointer<Int32>.alloc(1)
            p.memory = Int32((val) ? 1: 0)
            OCI_BindBoolean(st, name, p)
        default:
            assert(1==0)
        }
    }
    func execute(statement: String, params: [String: AnyObject]=[:]) throws -> Result  {
        guard let cn = cn else {
            throw OracleError.NotConnected
        }
        let st = OCI_StatementCreate(cn);
        let prepared = OCI_Prepare(st, statement)
        assert(prepared == 1)
        for (name, val) in params {
            //            var v = Int32(val as! Int)
            //            OCI_BindInt(st, name, &v)
            bind_type(st, name: name, val: val)
        }
        let executed = OCI_Execute(st);
        
        assert(executed==1)
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


