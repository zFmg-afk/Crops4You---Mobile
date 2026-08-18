const { createClient } = require('@supabase/supabase-js');
const WebSocket = require('ws');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing SUPABASE_URL or SUPABASE_ANON_KEY in environment variables.');
  process.exit(1);
}

const realtimeConfig = { transport: WebSocket };

const supabase = createClient(supabaseUrl, supabaseKey, { realtime: realtimeConfig });

const createAuthenticatedClient = (token) =>
  createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { autoRefreshToken: false, persistSession: false },
    realtime: realtimeConfig,
  });

module.exports = { supabase, createAuthenticatedClient };
