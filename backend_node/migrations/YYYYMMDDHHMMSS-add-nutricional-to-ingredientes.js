'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Ingredientes', 'calorias', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      defaultValue: null,
    });
    await queryInterface.addColumn('Ingredientes', 'proteinas', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      defaultValue: null,
    });
    await queryInterface.addColumn('Ingredientes', 'carbohidratos', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      defaultValue: null,
    });
    await queryInterface.addColumn('Ingredientes', 'grasas', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true,
      defaultValue: null,
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('Ingredientes', 'calorias');
    await queryInterface.removeColumn('Ingredientes', 'proteinas');
    await queryInterface.removeColumn('Ingredientes', 'carbohidratos');
    await queryInterface.removeColumn('Ingredientes', 'grasas');
  },
};