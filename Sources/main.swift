






import Foundation




public struct OracleService{
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
try b.open()
let cursor = try b.cursor()
let timestamp = NSDate().timeIntervalSince1970
//for i in 0...1000{
    try! cursor.execute("select * from trade where id=:id", params: ["id": 2])
    for r in cursor {
        print(r)
    }
    try! cursor.execute("select * from users where id=:id", params: ["id": 2])
    for r in cursor {
        print(r)
    }

//}
print(NSDate().timeIntervalSince1970 - timestamp)
// print(c?.connected)
// c = nil
// while true{

// }
