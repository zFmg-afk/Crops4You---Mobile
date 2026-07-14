require('dotenv').config();
const express = require('express');
const cors = require('cors');
const supabase = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Rutas
app.use('/health', require('./routes/health.routes'));
app.use('/status', require('./routes/health.routes'));
app.use('/parcelas', require('./routes/parcelas.routes'));

// Rutas de cultivos
app.use('/cultivos', require('./routes/cultivos.routes'));

app.use(require('./middlewares/errorHandler'));

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
