const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 8081;

// Middleware
app.use(cors());
app.use(express.json());

// Sample data
let products = [
  {
    id: '1',
    name: 'Laptop',
    barcode: '1234567890123',
    price: 15000.0,
    stock: 10,
    category: 'Electronics',
    description: 'High performance laptop'
  },
  {
    id: '2',
    name: 'Mouse',
    barcode: '1234567890124',
    price: 250.0,
    stock: 50,
    category: 'Electronics',
    description: 'Wireless mouse'
  }
];

let transactions = [
  {
    id: '1',
    productId: '1',
    productName: 'Laptop',
    type: 'sale',
    quantity: 2,
    price: 15000.0,
    total: 30000.0,
    date: new Date().toISOString()
  }
];

// Routes
app.get('/api/products', (req, res) => {
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === req.params.id);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  res.json(product);
});

app.post('/api/products', (req, res) => {
  const newProduct = {
    id: Date.now().toString(),
    ...req.body
  };
  products.push(newProduct);
  res.status(201).json(newProduct);
});

app.put('/api/products/:id', (req, res) => {
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }
  products[index] = { ...products[index], ...req.body };
  res.json(products[index]);
});

app.delete('/api/products/:id', (req, res) => {
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }
  products.splice(index, 1);
  res.status(204).send();
});

app.get('/api/transactions', (req, res) => {
  res.json(transactions);
});

app.post('/api/transactions', (req, res) => {
  const newTransaction = {
    id: Date.now().toString(),
    date: new Date().toISOString(),
    ...req.body
  };
  transactions.push(newTransaction);
  res.status(201).json(newTransaction);
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});