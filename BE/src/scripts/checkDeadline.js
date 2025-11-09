require('dotenv').config();
const db = require('../config/database');

async function checkDeadline() {
  try {
    const result = await db.query(`
      SELECT
        id,
        title,
        end_date,
        deadline,
        CURRENT_DATE,
        (end_date - CURRENT_DATE) as days_until_deadline
      FROM policies
      WHERE id = '20250814005400211517'
    `);

    console.log('Policy deadline calculation:');
    console.log(JSON.stringify(result.rows[0], null, 2));
    console.log('\nExplanation:');
    console.log('- end_date:', result.rows[0].end_date);
    console.log('- Current date:', result.rows[0].current_date);
    console.log('- Days until deadline (end_date - CURRENT_DATE):', result.rows[0].days_until_deadline);
    console.log('- deadline field:', result.rows[0].deadline);

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkDeadline();
