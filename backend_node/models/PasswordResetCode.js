'use strict';

module.exports = (sequelize, DataTypes) => {

  const PasswordResetCode = sequelize.define('PasswordResetCode', {

    email: {
      type: DataTypes.STRING,
      allowNull: false
    },

    codigo: {
      type: DataTypes.STRING(6),
      allowNull: false
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
    tableName: 'PasswordResetCodes',
    timestamps: true
  });

  return PasswordResetCode;

};