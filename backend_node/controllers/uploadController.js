const multer = require('multer');
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

exports.upload = multer({ storage: multer.memoryStorage() });

exports.uploadImagen = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se subió ninguna imagen' });
  }

  try {
    const result = await new Promise((resolve, reject) => {
      cloudinary.uploader.upload_stream(
        { folder: 'mymeal' },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      ).end(req.file.buffer);
    });

    res.json({ success: true, url: result.secure_url });
  } catch (error) {
    res.status(500).json({ error: 'Error al subir la imagen' });
  }
};

exports.eliminarImagen = async (req, res) => {
  const { filename } = req.params;
  if (!filename) {
    return res.status(400).json({ error: 'Nombre de archivo requerido' });
  }

  try {
    await cloudinary.uploader.destroy(`mymeal/${filename}`);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar la imagen' });
  }
};