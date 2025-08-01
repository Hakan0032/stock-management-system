const express = require('express');
const router = express.Router();
const {
  getAllMachines,
  getMachineById,
  createMachine,
  updateMachine,
  deleteMachine,
  getMachineStats
} = require('../controllers/machineController');
const { validateMachine } = require('../middleware/validation');

// GET /api/machines - Tüm makineleri getir
router.get('/', getAllMachines);

// GET /api/machines/stats - Makine istatistikleri
router.get('/stats', getMachineStats);

// GET /api/machines/:id - Belirli bir makineyi getir
router.get('/:id', getMachineById);

// POST /api/machines - Yeni makine oluştur
router.post('/', validateMachine, createMachine);

// PUT /api/machines/:id - Makineyi güncelle
router.put('/:id', validateMachine, updateMachine);

// DELETE /api/machines/:id - Makineyi sil
router.delete('/:id', deleteMachine);

module.exports = router;