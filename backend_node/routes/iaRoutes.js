const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const { generarPlanComidas, completarMenuConIA } = require('../services/groqService');
const db = require('../models');
const Usuario = db.Usuario;
const Ingrediente = db.Ingrediente;

router.post('/plan-comidas', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const user = await Usuario.findByPk(userId, {
            attributes: [
                'imc', 'tdee', 'objetivoRecomendado',
                'peso', 'altura',
            ],
        });

        if (!user || !user.tdee) {
            return res.status(400).json({
                error: 'Debes completar tu perfil nutricional primero',
            });
        }

        const ingredientes = await Ingrediente.findAll({
            where: { disponible: true },
            attributes: [
                'nombre', 'tipo', 'cantidad',
                'calorias', 'proteinas', 'carbohidratos', 'grasas',
            ],
        });

        if (ingredientes.length === 0) {
            return res.status(400).json({
                error: 'No hay ingredientes disponibles',
            });
        }

        const plan = await generarPlanComidas({
            perfil: user,
            ingredientes,
        });

        res.json({ success: true, plan });
    } catch (error) {
        console.error('Error generando plan:', error.message);
        res.status(500).json({ error: 'Error al generar el plan de comidas' });
    }
});

router.post('/completar-menu', verifyToken, async (req, res) => {
  try {
    const { nombre } = req.body;

    if (!nombre || nombre.trim().length < 2) {
      return res.status(400).json({
        error: 'El nombre del menú es requerido',
      });
    }

    const datos = await completarMenuConIA(nombre.trim());

    res.json({ success: true, datos });
  } catch (error) {
    console.error('Error completando menú con IA:', error.message);
    res.status(500).json({
      error: 'Error al completar el menú con IA',
    });
  }
});

module.exports = router;