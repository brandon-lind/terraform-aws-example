const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/status', (req, res) => {
  res.json({status:`UP at ${new Date().toString()}`});
});

app.get('/', (req, res) => {
  res.send('App2 OK');
});

app.listen(port, () => console.info(`App2 is listening on port ${port}`));
