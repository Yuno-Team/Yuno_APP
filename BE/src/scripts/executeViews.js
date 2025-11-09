require('dotenv').config();
const db = require('../config/database');
const fs = require('fs');
const path = require('path');

async function executeViews() {
  try {
    console.log('Reading views.sql file...');
    const viewsSQL = fs.readFileSync(
      path.join(__dirname, '../database/views.sql'),
      'utf8'
    );

    console.log('Executing SQL to create views...');
    await db.query(viewsSQL);

    console.log('✅ Database views created successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating views:', error);
    process.exit(1);
  }
}

executeViews();
