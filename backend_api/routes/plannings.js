const express = require('express');
const router = express.Router();
const {
  getAllPlannings,
  getPlanningById,
  createPlanning,
  updatePlanning,
  deletePlanning,
  getPlanningStats,
  getCategories
} = require('../controllers/planningController');
const { validatePlanning } = require('../middleware/validation');

// GET /api/plannings - Tüm planları getir
router.get('/', getAllPlannings);

// GET /api/plannings/stats - Plan istatistikleri
router.get('/stats', getPlanningStats);

// GET /api/plannings/categories - Kategorileri getir
router.get('/categories', getCategories);

// GET /api/plannings/:id - Belirli bir planı getir
router.get('/:id', getPlanningById);

// POST /api/plannings - Yeni plan oluştur
router.post('/', validatePlanning, createPlanning);

// PUT /api/plannings/:id - Planı güncelle
router.put('/:id', validatePlanning, updatePlanning);

// DELETE /api/plannings/:id - Planı sil
router.delete('/:id', deletePlanning);

module.exports = router;