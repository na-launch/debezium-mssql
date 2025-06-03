print("⏳ Waiting 5s for mongod to be ready...");
sleep(5000);

//const initialHost = "localhost:27017";
const initialHost = "localhost:27017";
// const dockerHost = "mongodb:27017";

print("🔧 Initiating replica set with:", initialHost);

try {
  const result = rs.initiate({
    _id: "rs0",
    members: [{ _id: 0, host: initialHost }]
  });
  print("✅ Replica set initiation result:", JSON.stringify(result));
} catch (e) {
  print("ℹ️ Replica set may already be initiated:", e.message);
}

// sleep(20000);

// print("⏳ Waiting for PRIMARY to be ready...");
// let retries = 20;
// while (retries > 0) {
//   try {
//     const status = rs.status();
//     if (status.ok && status.members[0].stateStr === "PRIMARY") {
//       print("✅ PRIMARY state confirmed.");
//       break;
//     } else {
//       print("⌛ Still waiting for PRIMARY...");
//     }
//   } catch (e) {
//     print("⏳ rs.status() check failed:", e.message);
//   }
//   sleep(1000);
//   retries--;
// }
// if (retries === 0) {
//   print("❌ PRIMARY not reached in time. Exiting.");
//   quit(1);
// }


print("📦 Creating seed data and users...");
try {
  db = db.getSiblingDB("testdb");
  db.createCollection("users");
  db.users.insertMany([
    { _id: 1, name: "Alice", email: "alice@example.com" },
    { _id: 2, name: "Bob", email: "bob@example.com" }
  ]);

  db.createUser({
    user: "debezium",
    pwd: "dbz",
    roles: [
      { role: "readWrite", db: "testdb" },
      { role: "read", db: "local" }
    ]
  });
} catch (e) {
  print("❌ Error creating seed data or user:", e.message);
  quit(1);
}


// rs.reconfig({_id: "rs0",members: [{ _id: 0, host: "mongodb:27017" }]}, { force: true })
// rs.status()