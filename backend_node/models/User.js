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

    // ── Datos físicos ─────────────────────────────────
    peso: {
      type: DataTypes.FLOAT,
      allowNull: true,  // en kg
    },

    altura: {
      type: DataTypes.FLOAT,
      allowNull: true,  // en cm
    },

    edad: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },

    sexo: {
      type: DataTypes.ENUM('masculino', 'femenino'),
      allowNull: true,
    },

    nivelActividad: {
      type: DataTypes.ENUM(
        'sedentario',       // poco o nada de ejercicio
        'ligero',           // ejercicio 1-3 días/semana
        'moderado',         // ejercicio 3-5 días/semana
        'activo',           // ejercicio 6-7 días/semana
        'muy_activo'        // ejercicio intenso diario
      ),
      allowNull: true,
    },

    // Se calcula automáticamente al guardar peso y altura
    imc: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },

    // Calorías diarias recomendadas
    tdee: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },

    // Objetivo recomendado según IMC
    objetivoRecomendado: {
      type: DataTypes.ENUM(
        'bajar_peso',
        'subir_musculo',
        'mantenimiento',
        'energia',
        'digestivo'
      ),
      allowNull: true,
    },

  }, {
    tableName: 'Usuarios',
    timestamps: true,

    // Calcular IMC y TDEE automáticamente antes de guardar
    hooks: {
      beforeSave: (usuario) => {
        if (usuario.peso && usuario.altura) {
          const alturaMetros = usuario.altura / 100;
          usuario.imc = parseFloat(
            (usuario.peso / (alturaMetros * alturaMetros)).toFixed(2)
          );

          // Recomendar objetivo según IMC
          if (usuario.imc < 18.5) {
            usuario.objetivoRecomendado = 'subir_musculo';
          } else if (usuario.imc <= 24.9) {
            usuario.objetivoRecomendado = 'mantenimiento';
          } else if (usuario.imc <= 29.9) {
            usuario.objetivoRecomendado = 'bajar_peso';
          } else {
            usuario.objetivoRecomendado = 'bajar_peso';
          }
        }

        // Calcular TDEE si tiene todos los datos
        if (usuario.peso && usuario.altura && usuario.edad &&
            usuario.sexo && usuario.nivelActividad) {

          // Fórmula Mifflin-St Jeor
          let tmb;
          if (usuario.sexo === 'masculino') {
            tmb = (10 * usuario.peso) +
                  (6.25 * usuario.altura) -
                  (5 * usuario.edad) + 5;
          } else {
            tmb = (10 * usuario.peso) +
                  (6.25 * usuario.altura) -
                  (5 * usuario.edad) - 161;
          }

          // Factor de actividad
          const factores = {
            sedentario:  1.2,
            ligero:      1.375,
            moderado:    1.55,
            activo:      1.725,
            muy_activo:  1.9,
          };

          usuario.tdee = parseFloat(
            (tmb * factores[usuario.nivelActividad]).toFixed(2)
          );
        }
      }
    }
  });

  User.associate = function(models) {
    User.hasMany(models.Direccion, {
      foreignKey: 'usuarioId',
      onDelete: 'CASCADE'
    });
  };

  return User;
};