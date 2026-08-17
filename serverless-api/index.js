require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const upload = require('express-fileupload');
const serverless = require('@vendia/serverless-express');

const db = require(__dirname + '/api/services/service.js');
const router = require(__dirname + '/api/routes/routes.js');

// 1. Initialize Express App
const app = express();

// 2. Attach Middleware
app.use(bodyParser.json());
app.use(upload());

// 3. Attach Routes
app.use('/', router);

// 4. Database Syncing (Non-blocking for lab environments)
db.then(database => {
  database.sync().then(() => {
    console.log('Tables created successfully!');
  }).catch((error) => {
    console.error('Unable to create tables:', error);
  });
}).catch(err => console.error('DB Connection Error:', err));

// 5. Environment Execution Switch
if (process.env.ENVIRONMENT === 'lambda') {
  // Lambda Entrypoint
  exports.handler = serverless({ app });
} else {
  // Local Server Entrypoint
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running locally on port ${PORT}`);
  });
}
