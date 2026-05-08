const axios = require('axios');
const { translate } = require('@vitalets/google-translate-api');

const USDA_API_KEY = process.env.USDA_API_KEY;
const BASE_URL = 'https://api.nal.usda.gov/fdc/v1';

async function buscarNutricional(nombre) {
  // Traducir al inglés primero
  let nombreIngles = nombre;
  try {
    const traduccion = await translate(nombre, { to: 'en' });
    nombreIngles = traduccion.text;
    console.log(`Traducido: "${nombre}" → "${nombreIngles}"`);
  } catch (e) {
    console.warn('Error al traducir, usando nombre original:', e.message);
  }

  const response = await axios.get(`${BASE_URL}/foods/search`, {
    params: {
      query: nombreIngles,
      api_key: USDA_API_KEY,
      pageSize: 5,
      dataType: 'Foundation,SR Legacy',
    },
  });

  const foods = response.data.foods;
  if (!foods || foods.length === 0) return null;

  const food = foods[0];
  const nutrients = food.foodNutrients;

  const get = (name) => {
    const n = nutrients.find((n) => n.nutrientName === name);
    return n ? parseFloat(n.value.toFixed(1)) : 0;
  };

  return {
    nombre: food.description,
    calorias: get('Energy'),
    proteinas: get('Protein'),
    carbohidratos: get('Carbohydrate, by difference'),
    grasas: get('Total lipid (fat)'),
  };
}

module.exports = { buscarNutricional };