require('dotenv').config();
const express = require('express');
const cors = require('cors');
const supabase = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

(async () => {
  const { error } = await supabase.from('parcelas').select('count', { count: 'exact', head: true });
  if (error) {
    console.error('mal:', error.message);
  } else {
    console.log('Servidor conectado a la bd de supabase caon');
  }

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
})();
