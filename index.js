const express = require('express');
const cors = require('cors');
// const { listarPets, criarPet } = require('./app/controller/petController');

const app = express();
app.use(cors());
app.use(express.json());

// app.get('/pets', listarPets);
// app.post('/pets', criarPet);

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));