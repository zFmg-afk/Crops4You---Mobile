const OPENWEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
const OPENWEATHER_FORECAST_URL = 'https://api.openweathermap.org/data/2.5/forecast';

exports.obtenerClima = async (lat, lon) => {
  if (lat === undefined || lon === undefined || lat === '' || lon === '') {
    throw { status: 400, message: 'Se requieren lat y lon como query params' };
  }

  const apiKey = process.env.OPENWEATHER_KEY;
  if (!apiKey) {
    throw { status: 500, message: 'OPENWEATHER_KEY no configurada en el backend' };
  }

  const url = `${OPENWEATHER_BASE_URL}?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=es`;

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);

  let response;
  try {
    response = await fetch(url, { signal: controller.signal });
  } catch {
    throw { status: 503, message: 'No se pudo obtener el clima: OpenWeather no responde' };
  } finally {
    clearTimeout(timeout);
  }

  if (!response.ok) {
    throw { status: 503, message: 'No se pudo obtener el clima: OpenWeather no responde' };
  }

  const data = await response.json();

  if (!data.main || !Array.isArray(data.weather) || data.weather.length === 0) {
    throw { status: 503, message: 'Respuesta inválida de OpenWeather' };
  }

  return {
    temperatura: data.main.temp,
    sensacion_termica: data.main.feels_like,
    humedad: data.main.humidity,
    condicion: data.weather[0].description,
    icono: data.weather[0].icon || null,
    viento: data.wind ? data.wind.speed : null,
    presion: data.main.pressure ?? null,
    ciudad: data.name || null,
    timestamp: new Date().toISOString(),
  };
};

exports.obtenerPronostico = async (lat, lon) => {
  if (lat === undefined || lon === undefined || lat === '' || lon === '') {
    throw { status: 400, message: 'Se requieren lat y lon como query params' };
  }

  const apiKey = process.env.OPENWEATHER_KEY;
  if (!apiKey) {
    throw { status: 500, message: 'OPENWEATHER_KEY no configurada en el backend' };
  }

  const url = `${OPENWEATHER_FORECAST_URL}?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=es&cnt=40`;

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);

  let response;
  try {
    response = await fetch(url, { signal: controller.signal });
  } catch {
    throw { status: 503, message: 'No se pudo obtener el pronóstico: OpenWeather no responde' };
  } finally {
    clearTimeout(timeout);
  }

  if (!response.ok) {
    throw { status: 503, message: 'No se pudo obtener el pronóstico: OpenWeather no responde' };
  }

  const data = await response.json();

  if (!Array.isArray(data.list) || data.list.length === 0) {
    throw { status: 503, message: 'Respuesta inválida de OpenWeather' };
  }

  return { list: data.list };
};
