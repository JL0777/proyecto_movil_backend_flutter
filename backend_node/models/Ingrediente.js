'use strict';

module.exports = (sequelize, DataTypes) => {
    const Ingrediente = sequelize.define('Ingrediente', {
        nombre: {
            type: DataTypes.STRING,
            allowNull: false
        },
        tipo: {
            type: DataTypes.ENUM(
                'proteina',
                'legumbre',
                'carbohidrato',
                'vegetal',
                'bebida',
                'complemento',
                'pan',
                'salsa',
                'extra'
            ),
            allowNull: false
        },
        cantidad: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
            defaultValue: 0
        },
        precio: {
            type: DataTypes.DECIMAL(10, 2),
            defaultValue: 0
        },
        disponible: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        calorias: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
            defaultValue: null
        },
        proteinas: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
            defaultValue: null
        },
        carbohidratos: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
            defaultValue: null
        },
        grasas: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
            defaultValue: null
        },
    }, {
        tableName: 'Ingredientes',
        timestamps: true
    });

    Ingrediente.associate = function (models) {
        Ingrediente.hasMany(models.DetallePedido, {
            foreignKey: 'ingredienteId'
        });
    };

    return Ingrediente;
};