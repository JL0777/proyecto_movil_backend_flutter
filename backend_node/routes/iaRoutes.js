const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const db = require('../models');
const Usuario = db.Usuario;
const Ingrediente = db.Ingrediente;
const { generarPlanComidas, completarMenuConIA, analizarFotoComida } = require('../services/groqService');

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

router.post('/analizar-foto', verifyToken, async (req, res) => {
  try {
    const { imagen, mimeType } = req.body;

    if (!imagen) {
      return res.status(400).json({ success: false, error: 'Imagen requerida' });
    }

    const resultado = await analizarFotoComida(imagen, mimeType);
    return res.json({ success: true, resultado });

  } catch (error) {
    console.error('Error analizando foto completo:', error);

    // Error de cuota agotada
    if (error.status === 429) {
      return res.status(429).json({
        success: false,
        error: 'Límite de análisis alcanzado. Por favor intenta en unos minutos.',
      });
    }

    // Imagen sin comida detectada
    if (error.message === 'No se detectó comida en la imagen') {
      return res.status(422).json({ success: false, error: error.message });
    }

    return res.status(500).json({ success: false, error: 'Error al analizar la imagen' });
  }
});

module.exports = router;