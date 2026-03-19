'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {

    // CATEGORIAS
    await queryInterface.bulkInsert('Categorias', [
      // Tradicional
      { nombre: 'Desayuno', tipo: 'tradicional', icono: 'desayuno', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Almuerzo', tipo: 'tradicional', icono: 'almuerzo', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Cena', tipo: 'tradicional', icono: 'cena', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Rapida
      { nombre: 'Hamburguesas', tipo: 'rapida', icono: 'hamburguesas', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Perros', tipo: 'rapida', icono: 'perros', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Salchipapas', tipo: 'rapida', icono: 'salchipapas', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Bebidas
      { nombre: 'Gaseosas', tipo: 'bebida', icono: 'gaseosas', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Jugos Naturales', tipo: 'bebida', icono: 'jugos', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Cerveza', tipo: 'bebida', icono: 'cerveza', disponible: true, createdAt: new Date(), updatedAt: new Date() },
    ]);

    // INGREDIENTES
    await queryInterface.bulkInsert('Ingredientes', [
      // Proteinas
      { nombre: 'Pollo desmechado', tipo: 'proteina', cantidad: '180g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Carne molida', tipo: 'proteina', cantidad: '180g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Huevo', tipo: 'proteina', cantidad: '2 unidades', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Legumbres
      { nombre: 'Frijol Verde', tipo: 'legumbre', cantidad: '50g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Lenteja', tipo: 'legumbre', cantidad: '50g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Carbohidratos
      { nombre: 'Arroz', tipo: 'carbohidrato', cantidad: '50g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Papa a la francesa', tipo: 'carbohidrato', cantidad: '100g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Arepa', tipo: 'carbohidrato', cantidad: '1 unidad', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Vegetales
      { nombre: 'Ensalada de campo', tipo: 'vegetal', cantidad: '50g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Tomate', tipo: 'vegetal', cantidad: '50g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Bebidas
      { nombre: 'Coca Cola', tipo: 'bebida', cantidad: '225ml', precio: 4000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Jugo de lulo', tipo: 'bebida', cantidad: '300ml', precio: 3000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Agua', tipo: 'bebida', cantidad: '300ml', precio: 2000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      // Complementos
      { nombre: 'Sal', tipo: 'complemento', cantidad: 'sobre 1g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Salsa de tomate', tipo: 'complemento', cantidad: 'sobre 8g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Mayonesa', tipo: 'complemento', cantidad: 'sobre 8g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
    ]);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Ingredientes', null, {});
    await queryInterface.bulkDelete('Categorias', null, {});
  }
};