






import Foundation




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
let cursor = try b.cursor()
let timestamp = NSDate().timeIntervalSince1970
for i in 0..<1 {
//    try cursor.execute("select * from trade where  reject_reason_id is :reject_reason_id", params: ["reject_reason_id": nil])
//    for r in cursor {
//        print(r)
    try cursor.execute("insert into users (id, login, alive, trade_confirmation_type, can_limit_trade, can_market_trade) values (105, :2, :3, 1, 1, 1)", params: ["2": "іфвафівд", "3": 3,])
    print(cursor.affected)
}

print(NSDate().timeIntervalSince1970 - timestamp)

