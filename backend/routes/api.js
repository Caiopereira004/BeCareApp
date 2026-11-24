const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();
const User = require('../models/User');
const Fridge = require('../models/Fridge');
const Order = require('../models/Order');

const STRONG_PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]).{8,}$/;
const runtimeUsers = new Map();
let runtimeFridge = { temperature: 6.0, mode: 'Ideal' };

router.get('/status', (req, res) => res.json({ status: 'online', dbConnected: req.dbConnected }));

router.post('/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !email.includes('@')) return res.status(400).json({ error: 'Informe nome e um e-mail válido.' });
    if (!STRONG_PASSWORD_REGEX.test(password || '')) {
      return res.status(400).json({ error: 'Senha fraca. Use 8+ caracteres com maiúscula, minúscula, número e símbolo.' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    if (req.dbConnected) {
      if (await User.findOne({ email: email.toLowerCase() })) return res.status(409).json({ error: 'E-mail já cadastrado.' });
      const user = await User.create({ name: name.trim(), email: email.toLowerCase().trim(), password: hashedPassword });
      return res.status(201).json({ user: { id: user._id, name: user.name, email: user.email, skinType: null, skinGoal: null } });
    }
    if (runtimeUsers.has(email.toLowerCase())) return res.status(409).json({ error: 'E-mail já cadastrado.' });
    const newUser = { name: name.trim(), email: email.toLowerCase().trim(), password: hashedPassword, skinType: null, skinGoal: null };
    runtimeUsers.set(newUser.email, newUser);
    return res.status(201).json({ user: { name: newUser.name, email: newUser.email, skinType: null, skinGoal: null } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (req.dbConnected) {
      const user = await User.findOne({ email: (email || '').toLowerCase().trim() });
      if (!user || !(await bcrypt.compare(password, user.password))) return res.status(401).json({ error: 'Credenciais inválidas.' });
      const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
      return res.json({ token, user: { id: user._id, name: user.name, email: user.email, skinType: user.skinType, skinGoal: user.skinGoal } });
    }
    const user = runtimeUsers.get((email || '').toLowerCase().trim());
    if (!user || !(await bcrypt.compare(password, user.password))) return res.status(401).json({ error: 'Credenciais inválidas.' });
    return res.json({ user: { name: user.name, email: user.email, skinType: user.skinType, skinGoal: user.skinGoal } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/user/quiz', async (req, res) => {
  const { email, skinType, skinGoal } = req.body;
  try {
    if (req.dbConnected && email) {
      const user = await User.findOneAndUpdate({ email: email.toLowerCase() }, { skinType, skinGoal }, { new: true });
      return res.json({ success: true, user });
    }
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/fridge', async (req, res) => {
  if (req.dbConnected) {
    let fridge = await Fridge.findOne();
    if (!fridge) fridge = await Fridge.create({ ownerEmail: 'geral@glowup.com', temperature: 6.0, mode: 'Ideal' });
    return res.json(fridge);
  }
  res.json(runtimeFridge);
});

router.post('/fridge/temperature', async (req, res) => {
  const { temperature } = req.body;
  const mode = temperature >= 4 && temperature <= 8 ? 'Ideal' : 'Alerta';
  if (req.dbConnected) {
    const fridge = await Fridge.findOneAndUpdate({}, { temperature, mode, updatedAt: new Date() }, { upsert: true, new: true });
    return res.json(fridge);
  }
  runtimeFridge = { temperature, mode };
  res.json(runtimeFridge);
});

module.exports = router;
