const Groq = require('groq-sdk');

const client = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

async function generarPlanComidas({ perfil, ingredientes }) {
  const { tdee, objetivoRecomendado, imc } = perfil;

  const listaIngredientes = ingredientes
    .map((ing) => {
      const nutricional = ing.calorias
        ? `(${ing.calorias} kcal, ${ing.proteinas}g prot, ${ing.carbohidratos}g carbs, ${ing.grasas}g grasas por 100g)`
        : '(sin info nutricional)';
      return `- ${ing.nombre} [${ing.tipo}] ${nutricional}`;
    })
    .join('\n');

  const objetivoTexto = {
    bajar_peso: 'bajar de peso',
    subir_musculo: 'ganar músculo',
    mantenimiento: 'mantener su peso',
    energia: 'mejorar su energía',
    digestivo: 'mejorar su digestión',
  }[objetivoRecomendado] || objetivoRecomendado;

  const prompt = `Eres un nutricionista experto. Tu tarea es crear un plan de comidas para un día completo.

PERFIL DEL CLIENTE:
- IMC: ${imc}
- Calorías diarias recomendadas: ${tdee} kcal
- Objetivo: ${objetivoTexto}

INGREDIENTES DISPONIBLES EN EL RESTAURANTE:
${listaIngredientes}

INSTRUCCIONES:
1. Crea un plan con desayuno, almuerzo, merienda y cena
2. Usa ÚNICAMENTE los ingredientes de la lista
3. Especifica la cantidad en gramos de cada ingrediente
4. Calcula las calorías aproximadas de cada comida
5. El total del día debe estar cerca de ${tdee} kcal
6. Adapta las porciones al objetivo: ${objetivoTexto}
7. Responde en español, de forma clara y amigable
8. Usa este formato exacto:

🍳 DESAYUNO (~XXX kcal)
- Ingrediente: XXXg
Por qué: [explicación breve]

🥗 ALMUERZO (~XXX kcal)
- Ingrediente: XXXg
Por qué: [explicación breve]

🍎 MERIENDA (~XXX kcal)
- Ingrediente: XXXg
Por qué: [explicación breve]

🍽️ CENA (~XXX kcal)
- Ingrediente: XXXg
Por qué: [explicación breve]

💧 HIDRATACIÓN
[Recomendación de agua]

✅ RESUMEN DEL DÍA
Total calorías: ~XXX kcal
Consejo: [consejo personalizado]`;

  const completion = await client.chat.completions.create({
    model: 'llama-3.3-70b-versatile',
    max_tokens: 1500,
    messages: [
      {
        role: 'system',
        content: 'Eres un nutricionista experto que habla español. Siempre respondes en español.',
      },
      {
        role: 'user',
        content: prompt,
      },
    ],
  });

  return completion.choices[0].message.content;
}

async function completarMenuConIA(nombreMenu) {
  const prompt = `Eres un nutricionista y experto en gastronomía colombiana. 
El administrador de un restaurante quiere completar la información del siguiente plato:

PLATO: "${nombreMenu}"

Tu tarea es proporcionar:
1. Una descripción atractiva y apetitosa del plato (máximo 2 oraciones)
2. La información nutricional aproximada por porción estándar

Responde ÚNICAMENTE en este formato JSON exacto, sin texto adicional, sin markdown, sin bloques de código:
{
  "descripcion": "descripción atractiva del plato aquí",
  "calorias": número,
  "proteinas": número,
  "carbohidratos": número,
  "grasas": número
}`;

  const completion = await client.chat.completions.create({
    model: 'llama-3.3-70b-versatile',
    max_tokens: 500,
    messages: [
      {
        role: 'system',
        content: 'Eres un nutricionista experto en gastronomía colombiana. Respondes ÚNICAMENTE con JSON válido, sin texto adicional.',
      },
      {
        role: 'user',
        content: prompt,
      },
    ],
  });

  const texto = completion.choices[0].message.content.trim();
  return JSON.parse(texto);
}

async function analizarFotoComida(imagen, mimeType) {
  try {
    const completion = await client.chat.completions.create({
      model: 'meta-llama/llama-4-scout-17b-16e-instruct',
      max_tokens: 1000,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image_url',
              image_url: {
                url: `data:${mimeType || 'image/jpeg'};base64,${imagen}`,
              },
            },
            {
              type: 'text',
              text: `Analiza esta imagen de comida y responde ÚNICAMENTE con un objeto JSON válido.
No incluyas texto antes ni después, solo el JSON puro.
Usa exactamente esta estructura:
{
  "nombre": "Nombre del plato o alimento identificado",
  "emoji": "Un emoji que represente el plato",
  "porcion": "Descripción de la porción estimada (ej: 1 plato mediano, 250g aprox)",
  "calorias": 000,
  "proteinas": 00,
  "carbohidratos": 00,
  "grasas": 00,
  "fibra": 0,
  "descripcion": "Descripción breve y positiva del plato en 1 oración",
  "consejo": "Un consejo nutricional corto y útil relacionado con este alimento",
  "semaforo": "verde" | "amarillo" | "rojo"
}
Reglas:
- Los valores numéricos son gramos (proteinas, carbohidratos, grasas, fibra) o kcal (calorias)
- semaforo: "verde" si es saludable, "amarillo" si es moderado, "rojo" si es poco saludable
- Si no puedes identificar comida en la imagen, devuelve: {"error": "No se detectó comida en la imagen"}
- Todos los valores son estimados para la porción visible`,
            },
          ],
        },
      ],
    });

    const texto = completion.choices[0].message.content.trim();
    console.log('Respuesta Groq Vision:', texto);

    const cleaned = texto
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();

    const resultado = JSON.parse(cleaned);

    if (resultado.error) {
      throw new Error(resultado.error);
    }

    return resultado;

  } catch (error) {
    console.error('ERROR GROQ COMPLETO:', JSON.stringify(error, null, 2));
    throw error;
  }
}

module.exports = { generarPlanComidas, completarMenuConIA, analizarFotoComida };