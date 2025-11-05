# Sistema de Control de Peso - Instrucciones

## Mecánicas Implementadas

### Control de Peso del Jugador
- **Peso inicial**: 50 unidades
- **Rango de peso**: 10 - 150 unidades
- **Controles**:
  - **Q**: Disminuir peso (-30 unidades por pulsación)
  - **E**: Aumentar peso (+30 unidades por pulsación)
  - **Espacio**: Interactuar con objetos cercanos

### Efectos del Peso

#### En el Movimiento
- **Más pesado**: Movimiento más lento, cae más rápido
- **Más liviano**: Movimiento más rápido, cae más lento

#### En las Interacciones
- **Si tu peso > peso del objeto**: Atraes el objeto hacia ti
- **Si tu peso < peso del objeto**: Empujas el objeto lejos de ti

### Objetos Interactuables
- Deben tener el script `InteractableObject` 
- Se pueden configurar con diferentes pesos usando `@export var object_weight`
- Automáticamente se agregan al grupo "interactable"
- El jugador detecta objetos en un radio de 100 píxeles

## Cómo Usar en tu Proyecto

### 1. Player Setup
- Usa el script `player.gd` modificado
- Asegúrate de que tu jugador sea un CharacterBody2D
- Opcionalmente, agrega un Label UI para mostrar el peso actual en `WeightUI/WeightLabel`

### 2. Crear Objetos Interactuables
```gdscript
# Opción 1: Usar el script base
var obj = RigidBody2D.new()
obj.set_script(preload("res://Scripts/interactable_object.gd"))
obj.object_weight = 25.0  # Peso personalizado

# Opción 2: En el editor, crear un RigidBody2D y agregar el script
# Luego configurar object_weight en el inspector
```

### 3. Input Map Configurado
- `decrease_weight`: Q
- `increase_weight`: E  
- `interact`: Espacio
- Mantiene los controles originales (WASD/flechas para movimiento, Enter para saltar)

## Objetos de Prueba
El mundo actual crea automáticamente objetos de prueba:
- **Cuadrado amarillo**: Peso 20 (más liviano que el jugador por defecto)
- **Cuadrado rojo**: Peso 80 (más pesado que el jugador por defecto)

## Próximos Pasos Sugeridos
1. **Efectos visuales**: Partículas cuando se atrae/empuja objetos
2. **Sonido**: Audio feedback para cambios de peso e interacciones
3. **Puzzles**: Diseñar niveles que requieran manipular el peso para resolver rompecabezas
4. **UI mejorada**: Indicador visual más elegante del peso actual
5. **Objetos especiales**: Algunos objetos que solo se pueden mover con pesos específicos

## Notas Técnicas
- El sistema usa `PhysicsShapeQueryParameters2D` para detectar objetos cercanos
- Los objetos interactuables son `RigidBody2D` para física realista
- Las fuerzas se limitan para evitar que los objetos vuelen demasiado
- El peso afecta tanto la velocidad como la gravedad del jugador