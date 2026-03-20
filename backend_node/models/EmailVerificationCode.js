'use strict';

module.exports = (sequelize, DataTypes) => {

  const EmailVerificationCode = sequelize.define('EmailVerificationCode', {

    email: {
      type: DataTypes.STRING,
      allowNull: false
    },

    codigo: {
      type: DataTypes.STRING(6),
      allowNull: false
    },

    password: {
      type: DataTypes.STRING,
      allowNull: false
    },

    telefono: {
      type: DataTypes.STRING,
      allowNull: true
    },

    expira_en: {
      type: DataTypes.DATE,
      allowNull: false
    },

    usado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }

  }, {
    tableName: 'EmailVerificationCodes',
    timestamps: true
  });

  return EmailVerificationCode;

};