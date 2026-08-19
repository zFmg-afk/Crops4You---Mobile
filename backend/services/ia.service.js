const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

const prompts = {
  cultivo: `Eres un experto agrónomo integrado en la app Crops4You, una plataforma de gestión agrícola para pequeños y medianos productores mexicanos. Analiza la imagen del cultivo y responde EXACTAMENTE en este formato, sin introducción ni texto adicional:

1. Estado general del cultivo
[Describe aquí el estado: saludable, enfermo, con estrés hídrico, etc.]

2. Problemas detectados
[Lista los problemas visibles: plagas, enfermedades, deficiencias nutricionales, etc. Si no hay problemas, indícalo.]

3. Recomendaciones para el agricultor
[Da recomendaciones específicas y prácticas para mejorar o mantener el cultivo.]

4. Nivel de urgencia
[Indica SOLO uno de estos valores: Bajo, Medio o Alto. Explica brevemente por qué.]

Responde en español. Si la imagen no muestra un cultivo agrícola, indícalo en el punto 1 y deja los demás vacíos.`,

  planta: `Eres un experto botánico integrado en la app Crops4You. Identifica la planta en la imagen y responde EXACTAMENTE en este formato, sin introducción ni texto adicional:

1. Nombre e identificación
[Nombre común y científico de la planta, con nivel de certeza.]

2. Características principales
[Describe las características visuales más importantes.]

3. Tipo de planta
[Indica si es de interior o exterior y sus condiciones ideales.]

4. Cuidados básicos
[Luz, agua, temperatura y suelo recomendados.]

5. Datos curiosos y usos
[Menciona usos comunes o datos interesantes sobre la planta.]

Responde en español. Si no puedes identificarla con certeza, da tu mejor aproximación.`
};

const analizar = async (base64Image, mimeType = 'image/jpeg', modo = 'cultivo') => {
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
  const prompt = prompts[modo] || prompts.cultivo;

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
    generationConfig: { temperature: 0.3, maxOutputTokens: 4096 }
  });

  return result.response.text();
};

module.exports = { analizar };