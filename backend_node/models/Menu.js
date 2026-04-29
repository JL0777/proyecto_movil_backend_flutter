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
    },

    //Campos nutricionales nuevos 
    calorias: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    proteinas: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    carbohidratos: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    grasas: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    objetivo: {
      type: DataTypes.ENUM(
        'bajar_peso',
        'subir_musculo',
        'mantenimiento',
        'energia',
        'digestivo'
      ),
      allowNull: true
    },
    beneficios: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: []
    },
    etiquetas: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: []
    },
    esBalanceado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false // solo true cuando el admin llena la info nutricional
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