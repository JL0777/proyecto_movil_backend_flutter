'use strict';

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('Usuario', {
    nombre: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    telefono: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    rol: {
      type: DataTypes.ENUM('cliente', 'admin', 'cocinero'),
      defaultValue: 'cliente',
    }
  });

  return User;
};