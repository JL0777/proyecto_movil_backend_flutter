const { Direccion } = require('../models');


// Obtener direcciones del usuario
exports.getAddresses = async (req, res) => {

  try {

    const addresses = await Direccion.findAll({
      where: { usuarioId: req.user.id }
    });

    res.json(addresses);

  } catch (error) {

    console.error(error);
    res.status(500).json({ error: "Error al obtener direcciones" });

  }

};


// Crear dirección
exports.createAddress = async (req, res) => {

  try {

    const {
      barrio,
      direccion,
      tipoVivienda,
      torreApartamento,
      instrucciones
    } = req.body;

    if (!barrio || !direccion || !tipoVivienda) {

      return res.status(400).json({
        error: "Barrio, dirección y tipo de vivienda son obligatorios"
      });

    }

    const address = await Direccion.create({

      usuarioId: req.user.id,
      barrio,
      direccion,
      tipoVivienda,
      torreApartamento,
      instrucciones

    });

    res.status(201).json(address);

  } catch (error) {

    console.error(error);
    res.status(500).json({ error: "Error al crear dirección" });

  }

};


// Editar dirección
exports.updateAddress = async (req, res) => {

  try {

    const address = await Direccion.findOne({
      where: {
        id: req.params.id,
        usuarioId: req.user.id
      }
    });

    if (!address) {
      return res.status(404).json({
        error: "Dirección no encontrada"
      });
    }

    await address.update(req.body);

    res.json(address);

  } catch (error) {

    console.error(error);
    res.status(500).json({
      error: "Error al actualizar dirección"
    });

  }

};


// Eliminar dirección
exports.deleteAddress = async (req, res) => {

  try {

    const address = await Direccion.findOne({
      where: {
        id: req.params.id,
        usuarioId: req.user.id
      }
    });

    if (!address) {

      return res.status(404).json({
        error: "Dirección no encontrada"
      });

    }

    await address.destroy();

    res.json({
      message: "Dirección eliminada correctamente"
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      error: "Error al eliminar dirección"
    });

  }

};