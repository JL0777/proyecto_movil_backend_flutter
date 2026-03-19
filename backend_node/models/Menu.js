'use strict';

module.exports = (sequelize, DataTypes) => {
  const Menu = sequelize.define('Menu', {
    nombre: {
      type: DataTypes.STRING,
      allowNull: false
    },
    descripcion: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    precio: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    imagenUrl: {
      type: DataTypes.STRING,
      allowNull: true
    },
    disponible: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'Menus',
    timestamps: true
  });

  Menu.associate = function(models) {
    Menu.belongsTo(models.Categoria, {
      foreignKey: 'categoriaId'
    });
    Menu.hasMany(models.DetallePedido, {
      foreignKey: 'menuId'
    });
  };

  return Menu;
};