const express = require('express');
const axios   = require('axios');

const app = express();
const port = process.env.PORT || 3000;
const app2URI = process.env.APP2URI; // Let it error if not set

app.get('/test', async (req, res, next) => {
  try {
    let app2Health = 'I have no idea';
    
    console.log(`Getting the status of App2 from: ${app2URI}`);

    const response = await axios.get(`http://${app2URI}/status`);
    const data = response.data;

    res.send(`App1 thinks App2 status is: ${data.status}`);
  } catch(e) {
    console.warn(`Could not get the status of App2 from: ${app2URI}`);
    next(e);
  }
});

app.get('/', (req, res) => {
  res.send('App1 OK');
});

app.listen(port, () => console.info(`App1 is listening on port ${port}`));
