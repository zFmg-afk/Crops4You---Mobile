exports.getStatus = () => {
  return {
    status: "ok",
    proyecto: "Crops4You",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
    mensaje: "Servidor backend funcionando correctamente ✅",
  };
};
