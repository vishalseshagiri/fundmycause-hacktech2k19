const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const firebase = require('firebase');

const app = express();

app.use(cors());
app.use(require('morgan')('dev'));
app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));
// app.use(express.static(path.join(__dirname, 'public')));

app.use(require('./routes'));

app.use((req, res, next) => {
    const err = new Error('Not Found');
    err.status = 404;
    next(err);
});

app.use((err, req, res) => {
    res.status(err.status || 500);

    res.json({
        errors: {
            message: err.message,
            error: {}
        }
    });
});


app.listen(8000, () => console.log('Server started on http://localhost:8000'));
