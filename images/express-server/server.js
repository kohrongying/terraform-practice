'use strict';

const express = require('express');
const http = require('http');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('hello world')
});

app.get('/call', (req, res) => {
//  const url = 'http://localhost:5000'
  const url = `http://${process.env.BASE_URL}`
   http.get(url, (resp) => {
        let data = '';

        // A chunk of data has been recieved.
        resp.on('data', (chunk) => {
          data += chunk;
        });

        // The whole response has been received. Print out the result.
        resp.on('end', () => {
          console.log(JSON.parse(data));
          res.send(JSON.parse(data));

        });

    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
console.log(`prcoess.env.BASE_URL is ${process.env.BASE_URL}:${process.env.BASE_URL_PORT}`)