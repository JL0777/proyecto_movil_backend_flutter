'use strict';

module.exports = (sequelize, DataTypes) => {
  const Categoria = sequelize.define('Categoria', {
    nombre: {
      type: DataTypes.STRING,
      allowNull: false
    },
    tipo: {
      type: DataTypes.ENUM('tradicional', 'rapida', 'bebida'),
      allowNull: false
    },
    icono: {
      type: DataTypes.STRING,
      allowNull: true
    },
    disponible: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'Categorias',
    timestamps: true
  });

  Categoria.associate = function(models) {
    Categoria.hasMany(models.Menu, {
      foreignKey: 'categoriaId',
      onDelete: 'CASCADE'
    });
  };

  return Categoria;
};