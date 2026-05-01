'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {

    // CATEGORIAS
    await queryInterface.bulkInsert('Categorias', [
      // Tradicional
      { nombre: 'Desayunos Colombianos', tipo: 'tradicional', icono: 'desayuno', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Almuerzos Ejecutivos', tipo: 'tradicional', icono: 'almuerzo', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Cenas', tipo: 'tradicional', icono: 'cena', disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Comida rápida
      { nombre: 'Hamburguesas', tipo: 'rapida', icono: 'hamburguesas', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Perros Calientes', tipo: 'rapida', icono: 'perros', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Salchipapas', tipo: 'rapida', icono: 'salchipapas', disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Bebidas
      { nombre: 'Gaseosas', tipo: 'bebida', icono: 'gaseosas', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Jugos Naturales', tipo: 'bebida', icono: 'jugos', disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Bebidas Alcohólicas', tipo: 'bebida', icono: 'cerveza', disponible: true, createdAt: new Date(), updatedAt: new Date() },
    ]);

    // INGREDIENTES
    await queryInterface.bulkInsert('Ingredientes', [
      // Proteínas
      { nombre: 'Pechuga de pollo a la plancha', tipo: 'proteina', cantidad: '200g', precio: 6000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Carne de res asada', tipo: 'proteina', cantidad: '200g', precio: 7000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Huevo frito', tipo: 'proteina', cantidad: '1 unidad', precio: 1000, disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Legumbres
      { nombre: 'Frijoles rojos', tipo: 'legumbre', cantidad: '150g', precio: 3000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Lentejas guisadas', tipo: 'legumbre', cantidad: '150g', precio: 2500, disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Carbohidratos
      { nombre: 'Arroz blanco', tipo: 'carbohidrato', cantidad: '200g', precio: 2000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Papa francesa', tipo: 'carbohidrato', cantidad: '150g', precio: 3000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Arepa blanca', tipo: 'carbohidrato', cantidad: '1 unidad', precio: 1500, disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Vegetales
      { nombre: 'Ensalada (lechuga, tomate, cebolla)', tipo: 'vegetal', cantidad: '100g', precio: 2500, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Tomate fresco', tipo: 'vegetal', cantidad: '50g', precio: 1000, disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Bebidas
      { nombre: 'Coca-Cola 350ml', tipo: 'bebida', cantidad: '350ml', precio: 4000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Jugo de lulo natural', tipo: 'bebida', cantidad: '400ml', precio: 5000, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Agua mineral', tipo: 'bebida', cantidad: '600ml', precio: 3000, disponible: true, createdAt: new Date(), updatedAt: new Date() },

      // Complementos
      { nombre: 'Sal', tipo: 'complemento', cantidad: '1g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Salsa de tomate', tipo: 'complemento', cantidad: '10g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
      { nombre: 'Mayonesa', tipo: 'complemento', cantidad: '10g', precio: 0, disponible: true, createdAt: new Date(), updatedAt: new Date() },
    ]);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Ingredientes', null, {});
    await queryInterface.bulkDelete('Categorias', null, {});
  }
};