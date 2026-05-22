'use strict';

module.exports = (sequelize, DataTypes) => {
  const DetallePedido = sequelize.define('DetallePedido', {
    cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1
    },
    precioUnitario: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    }
  }, {
    tableName: 'detallepedidos',
    timestamps: true
  });

  DetallePedido.associate = function(models) {
    DetallePedido.belongsTo(models.Pedido, {
      foreignKey: 'pedidoId'
    });
    DetallePedido.belongsTo(models.Menu, {
      foreignKey: 'menuId'
    });
    DetallePedido.belongsTo(models.Ingrediente, {
      foreignKey: 'ingredienteId'
    });
  };

  return DetallePedido;
};