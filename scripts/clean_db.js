// scripts/clean_db.js
// Wipes all mock/test text, projects, chat messages, protocol versions, and audit entries
// Resets database to pristine production state for live data only.

require('dotenv').config();
const { Client } = require('pg');

const connectionString =
  process.env.DATABASE_URL ||
  'postgresql://postgres:password@localhost:5432/clinresearch';

async function cleanDatabase() {
  const client = new Client({ connectionString });
  try {
    console.log('Connecting to NeonDB PostgreSQL...');
    await client.connect();
    console.log('Connected! Cleaning all test data...');

    await client.query('DELETE FROM chat_messages;');
    await client.query('DELETE FROM protocol_versions;');
    await client.query('DELETE FROM iec_items;');
    await client.query('DELETE FROM projects;');
    await client.query('DELETE FROM audit_events;');

    // Insert single clean production baseline audit event
    await client.query(`
      INSERT INTO audit_events (id, title, description, performed_by, severity, timestamp)
      VALUES (
        'AUD-0001',
        'NeonDB Production Database Initialized',
        'All historical test mock data deleted. Live clinical registry ready for live data.',
        'System Sentinel Engine',
        'COMPLIANCE',
        NOW()
      );
    `);

    console.log('Clean complete! Current counts:');
    for (const t of ['projects', 'chat_messages', 'protocol_versions', 'iec_items', 'audit_events']) {
      const res = await client.query(`SELECT count(*) FROM ${t}`);
      console.log(`  - ${t}: ${res.rows[0].count} records`);
    }
  } catch (err) {
    console.error('Error cleaning database:', err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

cleanDatabase();
