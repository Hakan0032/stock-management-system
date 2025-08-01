const { Machine } = require('../models');
const { Op } = require('sequelize');

// Tüm makineleri getir
const getAllMachines = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search = '',
      status = '',
      type = '',
      sortBy = 'createdAt',
      sortOrder = 'DESC'
    } = req.query;

    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    // Arama ve filtreleme koşulları
    const whereConditions = {};
    
    if (search) {
      whereConditions[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } },
        { location: { [Op.like]: `%${search}%` } }
      ];
    }
    
    if (status) {
      whereConditions.status = status;
    }
    
    if (type) {
      whereConditions.type = { [Op.like]: `%${type}%` };
    }

    const { count, rows } = await Machine.findAndCountAll({
      where: whereConditions,
      limit: parseInt(limit),
      offset: offset,
      order: [[sortBy, sortOrder.toUpperCase()]]
    });

    res.json({
      success: true,
      data: {
        machines: rows,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / parseInt(limit)),
          totalItems: count,
          itemsPerPage: parseInt(limit)
        }
      }
    });
  } catch (error) {
    console.error('Makineler getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makineler getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

// Tek makine getir
const getMachineById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const machine = await Machine.findByPk(id);
    
    if (!machine) {
      return res.status(404).json({
        success: false,
        message: 'Makine bulunamadı'
      });
    }

    res.json({
      success: true,
      data: machine
    });
  } catch (error) {
    console.error('Makine getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makine getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

// Yeni makine oluştur
const createMachine = async (req, res) => {
  try {
    const machineData = req.body;
    
    // Aynı isimde makine var mı kontrol et
    const existingMachine = await Machine.findOne({
      where: { name: machineData.name }
    });
    
    if (existingMachine) {
      return res.status(400).json({
        success: false,
        message: 'Bu isimde bir makine zaten mevcut'
      });
    }

    const machine = await Machine.create(machineData);

    res.status(201).json({
      success: true,
      message: 'Makine başarıyla oluşturuldu',
      data: machine
    });
  } catch (error) {
    console.error('Makine oluşturulurken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makine oluşturulurken bir hata oluştu',
      error: error.message
    });
  }
};

// Makine güncelle
const updateMachine = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    const machine = await Machine.findByPk(id);
    
    if (!machine) {
      return res.status(404).json({
        success: false,
        message: 'Makine bulunamadı'
      });
    }

    // Eğer isim değiştiriliyorsa, aynı isimde başka makine var mı kontrol et
    if (updateData.name && updateData.name !== machine.name) {
      const existingMachine = await Machine.findOne({
        where: {
          name: updateData.name,
          id: { [Op.ne]: id }
        }
      });
      
      if (existingMachine) {
        return res.status(400).json({
          success: false,
          message: 'Bu isimde bir makine zaten mevcut'
        });
      }
    }

    await machine.update(updateData);

    res.json({
      success: true,
      message: 'Makine başarıyla güncellendi',
      data: machine
    });
  } catch (error) {
    console.error('Makine güncellenirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makine güncellenirken bir hata oluştu',
      error: error.message
    });
  }
};

// Makine sil
const deleteMachine = async (req, res) => {
  try {
    const { id } = req.params;
    
    const machine = await Machine.findByPk(id);
    
    if (!machine) {
      return res.status(404).json({
        success: false,
        message: 'Makine bulunamadı'
      });
    }

    await machine.destroy();

    res.json({
      success: true,
      message: 'Makine başarıyla silindi'
    });
  } catch (error) {
    console.error('Makine silinirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makine silinirken bir hata oluştu',
      error: error.message
    });
  }
};

// Makine istatistikleri
const getMachineStats = async (req, res) => {
  try {
    const totalMachines = await Machine.count();
    const activeMachines = await Machine.count({ where: { status: 'active' } });
    const inactiveMachines = await Machine.count({ where: { status: 'inactive' } });
    const maintenanceMachines = await Machine.count({ where: { status: 'maintenance' } });
    
    // Makine türlerine göre dağılım
    const machinesByType = await Machine.findAll({
      attributes: [
        'type',
        [Machine.sequelize.fn('COUNT', Machine.sequelize.col('id')), 'count']
      ],
      group: ['type'],
      raw: true
    });

    res.json({
      success: true,
      data: {
        total: totalMachines,
        active: activeMachines,
        inactive: inactiveMachines,
        maintenance: maintenanceMachines,
        byType: machinesByType
      }
    });
  } catch (error) {
    console.error('Makine istatistikleri getirilirken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Makine istatistikleri getirilirken bir hata oluştu',
      error: error.message
    });
  }
};

module.exports = {
  getAllMachines,
  getMachineById,
  createMachine,
  updateMachine,
  deleteMachine,
  getMachineStats
};