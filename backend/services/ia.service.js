const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

const prompt = `Eres un experto agrónomo. Analiza esta imagen de un cultivo agrícola y proporciona:
1. Estado general del cultivo (saludable, enfermo, con estrés, etc.)
2. Posibles problemas detectados (plagas, enfermedades, deficiencias nutricionales, etc.)
3. Recomendaciones específicas para el agricultor
4. Nivel de urgencia (bajo, medio, alto)
Responde en español de forma clara y práctica.`;

const analizar = async (base64Image, mimeType = 'image/jpeg') => {
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

  const result = await model.generateContent({
    contents: [
      {
        role: 'user',
        parts: [
          { text: prompt },
          { inlineData: { mimeType, data: base64Image } }
        ]
      }
    ],
    generationConfig: { temperature: 0.4, maxOutputTokens: 4096 }
  });

  return result.response.text();
};

module.exports = { analizar };