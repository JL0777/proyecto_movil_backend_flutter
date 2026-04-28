'use strict';
const bcrypt = require('bcrypt');

module.exports = {
  async up(queryInterface, Sequelize) {
    const hashedAdmin = await bcrypt.hash('adminmymeal123', 10);
    const hashedCocina = await bcrypt.hash('cocinamymeal123', 10);

    await queryInterface.bulkInsert('usuarios', [
      {
        nombre: 'Administrador',
        email: 'admin.mymeal@gmail.com',
        password: hashedAdmin,
        rol: 'admin',
        createdAt: new Date(),
        updatedAt: new Date(),
/*************  Windsurf Command   *************/
  /**
   * Revert seed commands here.
   *
   * Example:
   * await queryInterface.bulkDelete('People', null, {});
   */
/*******  a55d619d-e423-4565-937a-1db45007c870  *******/      },
      {
        nombre: 'Cocina',
        email: 'cocina.mymeal@gmail.com',
        password: hashedCocina,
        rol: 'cocinero',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('usuarios', null, {});
  },
};