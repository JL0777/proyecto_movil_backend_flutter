'use strict';

module.exports = (sequelize, DataTypes) => {

  const Address = sequelize.define('Direccion', {

    barrio: {
      type: DataTypes.STRING,
      allowNull: false
    },

    direccion: {
      type: DataTypes.STRING,
      allowNull: false
    },

    tipoVivienda: {
      type: DataTypes.STRING,
      allowNull: false
    },

    torreApartamento: {
      type: DataTypes.STRING,
      allowNull: true
    },

    instrucciones: {
      type: DataTypes.TEXT,
      allowNull: true
    }

  }, {

    tableName: 'direcciones',  
    timestamps: true

  });

  Address.associate = function(models) {

    Address.belongsTo(models.Usuario, {
      foreignKey: 'usuarioId',
      onDelete: 'CASCADE'
    });

  };

  return Address;

};