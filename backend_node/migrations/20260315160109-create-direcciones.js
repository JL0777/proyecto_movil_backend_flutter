'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {

    await queryInterface.createTable('Direcciones', {

      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },

      usuarioId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Usuarios',
          key: 'id'
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE'
      },

      barrio: {
        type: Sequelize.STRING,
        allowNull: false
      },

      direccion: {
        type: Sequelize.STRING,
        allowNull: false
      },

      tipoVivienda: {
        type: Sequelize.STRING,
        allowNull: false
      },

      torreApartamento: {
        type: Sequelize.STRING,
        allowNull: true
      },

      instrucciones: {
        type: Sequelize.TEXT,
        allowNull: true
      },

      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },

      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }

    });

  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Direcciones');
  }
};