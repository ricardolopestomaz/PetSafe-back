require('dotenv').config(); // Carrega o arquivo .env
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());


app.get('/', (req, res) => {
  res.send('API PetSafe rodando com sucesso!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));