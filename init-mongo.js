db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || 'appdb');
db.createCollection('users');
db.createCollection('products');
db.createCollection('orders');
