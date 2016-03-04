



//DYLD_LIBRARY_PATH=/usr/local/oracle/instantclient
//NLS_LANG=RUSSIAN_RUSSIA.AL32UTF8

//import Foundation

#if os(OSX)
    import Darwin
#else
    import glibc
#endif



public struct OracleService {
    var raw_str: String?, host:String?, port:String?, service:String?
    init(from_string raw_str: String){
        self.raw_str = raw_str
    }
    init(host: String, port: String, service: String) {
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

//let timestamp = NSDate().timeIntervalSince1970
// var c: Connection? = Connection()
let service = OracleService(host: "dv", port:"1521", service: "xe")

let b = Connection(service: service, user:"broq", pwd:"anypassword")
var n = 0
try b.open()
b.autocommit = true
let timestamp = clock()

struct Asd {
    let ID : Int
    let TRDATA_PASSWORD: String?
    let DELETION_TIME: String?
    
}


let cursor = try b.cursor()

for i in 0..<1 {
    
    try cursor.execute("select * from users where login=:login or 1=1", params: ["login": "user2"])
    for r in cursor {
        print(r.dict)
        print(r.list)
        print(r["LOGIN"]!.string)
        print(r["ID"]!.int)
    }
    
    //    try cursor.execute("select * from sources where id=:id", params: ["id": 3])
    //    for r in cursor {
    //        print(r)
    ////    }
    //    try cursor.execute("select * from sources where reverse_enabled=:ids or 1=1", params: ["ids": 1.0 ])
    //        for r in cursor {
    //            print(r["OWNER"]! as? String)
    ////            print(r)
    //        }
    
    //    try cursor.execute("insert into users (id, login, alive) values (USERS_ID_SEQ.nextval, :2, :3) RETURNING id INTO :id ", params: ["2": "фіва", "3": 3,], register: ["id": .int])
    //    cursor.register("id", type: .int)
    
    //    for r in cursor {
    //        print(r)
    //    }
    
    //    print(cursor.affected)
}


print(Double(Int(clock())-Int(timestamp))/Double(CLOCKS_PER_SEC))

