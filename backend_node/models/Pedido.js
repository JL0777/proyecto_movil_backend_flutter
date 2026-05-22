'use strict';

module.exports = (sequelize, DataTypes) => {
  const Pedido = sequelize.define('Pedido', {
    tipo: {
      type: DataTypes.ENUM('predefinido', 'personalizado'),
      allowNull: false
    },
    estado: {
      type: DataTypes.ENUM('Pendiente', 'Activo', 'Realizado', 'Enviado'),
      defaultValue: 'Pendiente'
    },
    metodoPago: {
      type: DataTypes.ENUM('pse', 'contraentrega'),
      allowNull: false
    },
    subtotal: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    iva: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    total: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    }
  }, {
    tableName: 'pedidos',
    timestamps: true
  });

  Pedido.associate = function(models) {
    Pedido.belongsTo(models.Usuario, {
      foreignKey: 'usuarioId'
    });
    Pedido.belongsTo(models.Direccion, {
      foreignKey: 'direccionId'
    });
    Pedido.hasMany(models.DetallePedido, {
      foreignKey: 'pedidoId',
      onDelete: 'CASCADE'
    });
  };

  return Pedido;
};