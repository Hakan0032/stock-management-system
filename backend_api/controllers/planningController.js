const { Planning } = require('../models');
const { Op } = require('sequelize');

// Tüm planları getir
const getAllPlannings = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search = '',
      status = '',
      category = '',
      priority = '',
      sortBy = 'createdAt',
      sortOrder = 'DESC'
    } = req.query;

    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    // Arama ve filtreleme koşulları
    const whereConditions = {};
    
    if (search) {
      whereConditions[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } },
        { notes: { [Op.like]: `%${search}%` } }
      ];
    }
    
    if (status) {
      whereConditions.status = status;
    }
    
    if (category) {
      whereConditions.category = { [Op.like]: `%${category}%` };
    }
    
    if (priority) {
      whereConditions.priority = priority;
    }

    const { count, rows } = await Planning.findAndCountAll({
      where: whereConditions,
      limit: parseInt(limit),
      offset: offset,
      order: [[sortBy, sortOrder.toUpperCase()]]
    });

    res.json({
      success: true,
      data: {
        plannings: rows,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / parseInt(limit)),
          totalItems: count,
          itemsPerPage: parseInt(limit)
        }
      }
    });
  } catch (error) {
    console.error('Planlar getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Planlar getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

// Tek plan getir
const getPlanningById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const planning = await Planning.findByPk(id);
    
    if (!planning) {
      return res.status(404).json({
        success: false,
        message: 'Plan bulunamadı'
      });
    }

    res.json({
      success: true,
      data: planning
    });
  } catch (error) {
    console.error('Plan getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Plan getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

// Yeni plan oluştur
const createPlanning = async (req, res) => {
  try {
    const planningData = req.body;
    
    const planning = await Planning.create(planningData);

    res.status(201).json({
      success: true,
      message: 'Plan başarıyla oluşturuldu',
      data: planning
    });
  } catch (error) {
    console.error('Plan oluşturulurken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Plan oluşturulurken bir hata oluştu',
      error: error.message
    });
  }
};

// Plan güncelle
const updatePlanning = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    const planning = await Planning.findByPk(id);
    
    if (!planning) {
      return res.status(404).json({
        success: false,
        message: 'Plan bulunamadı'
      });
    }

    // Eğer status completed olarak değiştiriliyorsa, completedAt tarihini set et
    if (updateData.status === 'completed' && planning.status !== 'completed') {
      updateData.completedAt = new Date();
    }

    await planning.update(updateData);

    res.json({
      success: true,
      message: 'Plan başarıyla güncellendi',
      data: planning
    });
  } catch (error) {
    console.error('Plan güncellenirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Plan güncellenirken bir hata oluştu',
      error: error.message
    });
  }
};

// Plan sil
const deletePlanning = async (req, res) => {
  try {
    const { id } = req.params;
    
    const planning = await Planning.findByPk(id);
    
    if (!planning) {
      return res.status(404).json({
        success: false,
        message: 'Plan bulunamadı'
      });
    }

    await planning.destroy();

    res.json({
      success: true,
      message: 'Plan başarıyla silindi'
    });
  } catch (error) {
    console.error('Plan silinirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Plan silinirken bir hata oluştu',
      error: error.message
    });
  }
};

// Plan istatistikleri
const getPlanningStats = async (req, res) => {
  try {
    const totalPlannings = await Planning.count();
    const pendingPlannings = await Planning.count({ where: { status: 'pending' } });
    const inProgressPlannings = await Planning.count({ where: { status: 'in_progress' } });
    const completedPlannings = await Planning.count({ where: { status: 'completed' } });
    const cancelledPlannings = await Planning.count({ where: { status: 'cancelled' } });
    
    // Kategorilere göre dağılım
    const planningsByCategory = await Planning.findAll({
      attributes: [
        'category',
        [Planning.sequelize.fn('COUNT', Planning.sequelize.col('id')), 'count']
      ],
      group: ['category'],
      raw: true
    });
    
    // Öncelik seviyelerine göre dağılım
    const planningsByPriority = await Planning.findAll({
      attributes: [
        'priority',
        [Planning.sequelize.fn('COUNT', Planning.sequelize.col('id')), 'count']
      ],
      group: ['priority'],
      raw: true
    });

    res.json({
      success: true,
      data: {
        total: totalPlannings,
        pending: pendingPlannings,
        inProgress: inProgressPlannings,
        completed: completedPlannings,
        cancelled: cancelledPlannings,
        byCategory: planningsByCategory,
        byPriority: planningsByPriority
      }
    });
  } catch (error) {
    console.error('Plan istatistikleri getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Plan istatistikleri getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

// Kategorileri getir
const getCategories = async (req, res) => {
  try {
    const categories = await Planning.findAll({
      attributes: [
        [Planning.sequelize.fn('DISTINCT', Planning.sequelize.col('category')), 'category']
      ],
      raw: true
    });

    const categoryList = categories.map(item => item.category).filter(Boolean);

    res.json({
      success: true,
      data: categoryList
    });
  } catch (error) {
    console.error('Kategoriler getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Kategoriler getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

module.exports = {
  getAllPlannings,
  getPlanningById,
  createPlanning,
  updatePlanning,
  deletePlanning,
  getPlanningStats,
  getCategories
};