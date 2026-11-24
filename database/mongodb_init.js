use BeCareWeb;
db.createCollection("users");
db.users.createIndex({ "email": 1 }, { unique: true });
db.createCollection("fridges");
db.createCollection("orders");
