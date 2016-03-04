# SwiftOracle
OCILIB wrapper for Swift, linux compatible


This is beginning point for Oracle database adapter for Swift

This is wrapper for ocilib (https://github.com/vrogier/ocilib). 

PR are welcome.

Thats what you can do:

```swift
let service = OracleService(host: "dv", port:"1521", service: "xe")

let b = Connection(service: service, user:"broq", pwd:"anypassword")

try b.open()
b.autocommit = true


let cursor = try b.cursor()

try cursor.execute("select * from users where login=:login or 1=1", params: ["login": "user2"])
for r in cursor {
    print(r.dict)
    print(r.list)
    print(r["LOGIN"]!.string)
    print(r["ID"]!.int)
}

try cursor.execute("select * from sources where id=:id", params: ["id": 3])
for r in cursor {
    print(r)
}
try cursor.execute("select * from sources where reverse_enabled=:ids or 1=1", params: ["ids": 1.0 ])
for r in cursor {
    print(r["OWNER"]! as? String)
    print(r)
}

try cursor.execute("insert into users (id, login, alive) values (USERS_ID_SEQ.nextval, :2, :3) RETURNING id INTO :id ", params: ["2": "фіва", "3": 3,], register: ["id": .int])
cursor.register("id", type: .int)

for r in cursor {
    print(r)
}

print(cursor.affected)

```
