# 🎮 Proyecto Godot - Sistema de Control de Peso

## 📋 Descripción
Juego 2D desarrollado en **Godot 4** que implementa un sistema innovador de **control de peso dinámico** del personaje. El jugador puede modificar su peso para interactuar con objetos del entorno de diferentes maneras.

## ⚡ Mecánicas Principales

### 🎯 Sistema de Peso
- **Control dinámico**: El jugador puede aumentar o disminuir su peso
- **Rango**: 30-100 unidades de peso
- **Efectos**: 
  - Peso afecta velocidad de movimiento
  - Peso afecta altura de salto
  - Peso afecta gravedad aplicada

### 🔄 Interacciones con Objetos
- **Peso mayor que objeto**: Atrae el objeto hacia el jugador
- **Peso menor que objeto**: El objeto atrae al jugador
- **Pesos iguales**: Empuje mutuo

## 🎮 Controles
- **WASD / Flechas**: Movimiento
- **Enter**: Saltar
- **Q**: Disminuir peso (-10 unidades)
- **E**: Aumentar peso (+10 unidades)
- **F**: Interactuar con objetos cercanos
- **ESC**: Pausar juego

## 🛠️ Estructura del Proyecto

### 📁 Carpetas principales
- `Scripts/`: Scripts de GDScript (.gd)
- `Scenes/`: Escenas del juego (.tscn)
- `MusicaYSonido/`: Assets de audio
- `2D-Pixel-Art-Character-Template/`: Sprites del personaje

### 📄 Scripts importantes
- `player.gd`: Sistema de peso y controles del jugador
- `interactable_object.gd`: Clase base para objetos interactuables
- `mundo.gd`: Lógica del mundo principal
