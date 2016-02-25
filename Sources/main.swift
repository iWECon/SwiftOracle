











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


// var c: Connection? = Connection()
let service = OracleService(host: "dv", port:"1521", service: "xe")

let b = Connection(service: service, user:"broq", pwd:"anypassword")
try b.open()
//for i in 0...100000{
let res = try! b.execute("select * from trade")
    let r = res[3]

    print(r["USER_ID"] as! Int)
    print(r["QUOTE_ID"] as! String)
//}


// print(c?.connected)
// c = nil
// while true{

// }
