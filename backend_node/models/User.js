'use strict';

module.exports = (sequelize, DataTypes) => {

  const User = sequelize.define('Usuario', {

    nombre: {
      type: DataTypes.STRING,
      allowNull: true
    },

    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },

    password: {
      type: DataTypes.STRING,
      allowNull: false
    },

    telefono: {
      type: DataTypes.STRING,
      allowNull: true
    },

    rol: {
      type: DataTypes.ENUM('cliente', 'admin', 'cocinero'),
      defaultValue: 'cliente'
    },

    fotoPerfil: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: null
    },

  }, {
    tableName: 'Usuarios',
    timestamps: true
  });

  User.associate = function(models) {
    User.hasMany(models.Direccion, {
      foreignKey: 'usuarioId',
      onDelete: 'CASCADE'
    });
  };

  return User;
};