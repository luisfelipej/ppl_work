# 🧪 Testing Checklist - PplWork Backend

Checklist sistemático para verificar todas las funcionalidades del backend.

## Setup Inicial

- [ ] PostgreSQL está corriendo (`make db-up`)
- [ ] Base de datos creada (`mix ecto.create`)
- [ ] Migraciones ejecutadas (`mix ecto.migrate`)
- [ ] Seeds cargados (`mix run priv/repo/seeds.exs`)
- [ ] Servidor Phoenix corriendo (`make server`)

---

## API REST - Usuarios

### Registro de Usuarios

- [ ] ✅ Registrar usuario con datos válidos
- [ ] ✅ Recibir respuesta con ID de usuario
- [ ] ❌ Rechazar email inválido (sin @)
- [ ] ❌ Rechazar email duplicado
- [ ] ❌ Rechazar username duplicado
- [ ] ❌ Rechazar username muy corto (< 3 caracteres)
- [ ] ❌ Rechazar username muy largo (> 20 caracteres)
- [ ] ❌ Rechazar username con caracteres inválidos
- [ ] ❌ Rechazar password muy corta (< 8 caracteres)
- [ ] ❌ Rechazar password sin mayúscula
- [ ] ❌ Rechazar password sin minúscula
- [ ] ❌ Rechazar password sin número

**Comandos de prueba:**
```bash
# ✅ Válido
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "valid@test.com", "username": "valid123", "password": "Password123"}}'

# ❌ Email inválido
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "invalid", "username": "test", "password": "Password123"}}'
```

### Login de Usuarios

- [ ] ✅ Login exitoso con credenciales correctas
- [ ] ✅ Recibir datos de usuario (id, email, username)
- [ ] ❌ Rechazar login con password incorrecta
- [ ] ❌ Rechazar login con email no existente
- [ ] ❌ Verificar que password hasheada no se expone

**Comandos de prueba:**
```bash
# ✅ Login correcto
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@pplwork.com", "password": "Password123"}'

# ❌ Password incorrecta
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@pplwork.com", "password": "WrongPassword"}'
```

### Obtener Usuario

- [ ] ✅ Obtener usuario por ID válido
- [ ] ❌ Error 404 para ID no existente
- [ ] ✅ Verificar que password_hash no se expone en respuesta

---

## API REST - Espacios

### Listar Espacios

- [ ] ✅ Listar todos los espacios públicos
- [ ] ✅ Verificar que espacios privados NO aparecen
- [ ] ✅ Recibir array de espacios
- [ ] ✅ Verificar campos: id, name, width, height, description, is_public, max_occupancy

**Comando de prueba:**
```bash
curl http://localhost:4000/api/spaces | jq
```

### Crear Espacio

- [ ] ✅ Crear espacio con datos válidos
- [ ] ✅ Recibir respuesta con ID del espacio
- [ ] ✅ Crear espacio con valores por defecto (width, height, max_occupancy)
- [ ] ❌ Rechazar name muy corto (< 3 caracteres)
- [ ] ❌ Rechazar name muy largo (> 100 caracteres)
- [ ] ❌ Rechazar width <= 0
- [ ] ❌ Rechazar height <= 0
- [ ] ❌ Rechazar width > 1000
- [ ] ❌ Rechazar height > 1000
- [ ] ❌ Rechazar max_occupancy <= 0
- [ ] ❌ Rechazar max_occupancy > 500

**Comandos de prueba:**
```bash
# ✅ Válido
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{"space": {"name": "Test Space", "width": 100, "height": 100}}'

# ❌ Name muy corto
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{"space": {"name": "Ab", "width": 100, "height": 100}}'
```

### Obtener Espacio

- [ ] ✅ Obtener espacio por ID válido
- [ ] ❌ Error 404 para ID no existente
- [ ] ✅ Verificar todos los campos del espacio

### Actualizar Espacio

- [ ] ✅ Actualizar name
- [ ] ✅ Actualizar max_occupancy
- [ ] ✅ Actualizar description
- [ ] ✅ Actualizar is_public
- [ ] ✅ Actualización parcial (solo algunos campos)
- [ ] ❌ Rechazar valores inválidos (mismas validaciones que create)

### Eliminar Espacio

- [ ] ✅ Eliminar espacio existente
- [ ] ✅ Recibir status 204 No Content
- [ ] ✅ Verificar que espacio ya no existe (404 al consultar)
- [ ] ❌ Error al intentar eliminar espacio ya eliminado

### Ocupación de Espacio

- [ ] ✅ Obtener ocupancy de espacio vacío (current_occupancy: 0)
- [ ] ✅ Verificar at_capacity: false cuando hay espacio
- [ ] ✅ Verificar campos: space_id, current_occupancy, max_occupancy, at_capacity

---

## WebSockets - Conexión y Join

### Conexión al Socket

- [ ] ✅ Conectar socket exitosamente
- [ ] ✅ Recibir confirmación de conexión
- [ ] ✅ Socket permanece conectado

**Test en browser console:**
```javascript
const socket = new Phoenix.Socket("/socket")
socket.connect()
console.log("Socket connected:", socket.isConnected())
```

### Join a un Canal/Espacio

- [ ] ✅ Join a espacio con user_id y space_id válidos
- [ ] ✅ Recibir respuesta "ok" con datos del espacio
- [ ] ✅ Recibir current_avatar en respuesta
- [ ] ✅ Recibir lista de avatares actuales
- [ ] ✅ Recibir proximity_groups
- [ ] ✅ Avatar creado con posición inicial (x, y)
- [ ] ✅ Avatar creado con dirección por defecto
- [ ] ❌ Error al join con space_id no existente
- [ ] ❌ Error al join con user_id no existente
- [ ] ❌ Error al join cuando espacio está a capacidad máxima

**Test en browser console:**
```javascript
const channel = socket.channel("space:1", {
  user_id: 1,
  x: 50,
  y: 50
})

channel.join()
  .receive("ok", resp => console.log("Joined!", resp))
  .receive("error", resp => console.log("Error:", resp))
```

---

## WebSockets - Eventos

### Evento: user_joined

- [ ] ✅ Recibir evento cuando otro usuario entra
- [ ] ✅ Evento contiene user_id
- [ ] ✅ Evento contiene avatar con todos sus datos
- [ ] ✅ Evento se recibe en todos los clientes del espacio

### Evento: user_moved

- [ ] ✅ Recibir evento cuando otro usuario se mueve
- [ ] ✅ Evento contiene nueva posición (x, y)
- [ ] ✅ Evento contiene nueva dirección
- [ ] ✅ Evento se recibe en todos los clientes del espacio (excepto el que se movió)

### Evento: user_left

- [ ] ✅ Recibir evento cuando usuario sale (leave o disconnect)
- [ ] ✅ Evento contiene user_id
- [ ] ✅ Avatar marcado como inactive en BD

### Evento: proximity_update

- [ ] ✅ Recibir evento cuando cambia proximidad
- [ ] ✅ Evento contiene proximity_groups
- [ ] ✅ proximity_groups es un mapa de avatar_id → [nearby_avatar_ids]
- [ ] ✅ Se dispara al hacer join
- [ ] ✅ Se dispara al moverse
- [ ] ✅ Se dispara cuando alguien más se mueve cerca

---

## WebSockets - Acciones

### Acción: move

- [ ] ✅ Mover avatar a nueva posición válida
- [ ] ✅ Recibir confirmación con nueva posición
- [ ] ✅ Posición actualizada en BD
- [ ] ✅ Otros usuarios reciben evento user_moved
- [ ] ✅ Cambiar dirección del avatar
- [ ] ✅ Posición se valida dentro de límites del espacio
- [ ] ✅ Posiciones negativas se ajustan a 0
- [ ] ✅ Posiciones fuera de límites se ajustan al máximo

**Test:**
```javascript
testChannel.push("move", {x: 25, y: 30, direction: "up"})
  .receive("ok", resp => console.log("Moved:", resp))
```

### Acción: get_nearby_users

- [ ] ✅ Obtener usuarios dentro de radio especificado
- [ ] ✅ Radio por defecto es 5.0
- [ ] ✅ Recibir lista de nearby_users
- [ ] ✅ Cada usuario tiene: id, username, x, y, direction
- [ ] ✅ No incluye al usuario actual
- [ ] ✅ Calcula distancia euclidiana correctamente

**Test:**
```javascript
testChannel.push("get_nearby_users", {radius: 10.0})
  .receive("ok", resp => console.log("Nearby:", resp.nearby_users))
```

### Acción: get_state

- [ ] ✅ Obtener estado actual del espacio
- [ ] ✅ Recibir lista de todos los avatares
- [ ] ✅ Recibir proximity_groups
- [ ] ✅ Solo avatares activos

**Test:**
```javascript
testChannel.push("get_state", {})
  .receive("ok", resp => console.log("State:", resp))
```

### Acción: leave

- [ ] ✅ Salir del espacio exitosamente
- [ ] ✅ Avatar marcado como inactive
- [ ] ✅ Otros usuarios reciben evento user_left
- [ ] ✅ Canal se cierra

---

## Phoenix Presence

- [ ] ✅ Usuario se trackea al hacer join
- [ ] ✅ Usuario se des-trackea al hacer leave
- [ ] ✅ Presence incluye avatar_id
- [ ] ✅ Presence incluye online_at timestamp
- [ ] ✅ Verificar presence en IEx: `PplWorkWeb.Presence.list("space:1")`

---

## Lógica de Negocio

### Proximidad

- [ ] ✅ Distancia euclidiana se calcula correctamente
  - [ ] Distancia entre (0,0) y (3,4) = 5.0
  - [ ] Distancia entre (0,0) y (0,0) = 0.0
  - [ ] Distancia entre (10,10) y (12,12) ≈ 2.83
- [ ] ✅ find_nearby_avatars encuentra correctamente usuarios cercanos
- [ ] ✅ Radio por defecto es 5.0
- [ ] ✅ get_proximity_groups genera mapa correcto

**Test en IEx:**
```elixir
PplWork.World.calculate_distance(0, 0, 3, 4) # debería ser 5.0
PplWork.World.find_nearby_avatars(1, 10.0, 10.0, 5.0)
PplWork.World.get_proximity_groups(1, 5.0)
```

### Capacidad de Espacios

- [ ] ✅ space_at_capacity? devuelve false cuando hay espacio
- [ ] ✅ space_at_capacity? devuelve true cuando está lleno
- [ ] ✅ get_space_occupancy cuenta avatares activos correctamente
- [ ] ✅ join_space rechaza cuando espacio está lleno
- [ ] ❌ Error "space_at_capacity" cuando se intenta entrar a espacio lleno

**Test manual:**
1. Crear espacio con max_occupancy: 2
2. Conectar 2 usuarios
3. Intentar conectar 3er usuario (debe fallar)
4. Verificar occupancy endpoint

### Movimiento y Validaciones

- [ ] ✅ Posiciones dentro de límites se aceptan
- [ ] ✅ Posiciones fuera se ajustan a límites (clamping)
- [ ] ✅ validate_position_bounds funciona correctamente
- [ ] ✅ Direcciones válidas: up, down, left, right
- [ ] ❌ Rechazar direcciones inválidas

### Avatares

- [ ] ✅ Crear avatar al hacer join por primera vez
- [ ] ✅ Reactivar avatar existente si ya había entrado antes
- [ ] ✅ Posición inicial por defecto es centro del espacio
- [ ] ✅ Posición inicial customizable al hacer join
- [ ] ✅ Avatar se marca como inactive al hacer leave
- [ ] ✅ Solo un avatar por usuario por espacio (unique constraint)

---

## Tests Automatizados

### Unit Tests

- [ ] ✅ `mix test test/ppl_work/accounts_test.exs` pasa
- [ ] ✅ `mix test test/ppl_work/spaces_test.exs` pasa
- [ ] ✅ `mix test test/ppl_work/world_test.exs` pasa
- [ ] ✅ `mix test` (todos los tests) pasa

### Integration Tests

- [ ] ✅ Script `./test_api.sh` ejecuta exitosamente
- [ ] ✅ Todos los tests del script pasan
- [ ] ✅ Success rate: 100%

---

## Escenarios de Integración

### Escenario 1: Usuario Nuevo Completo

1. - [ ] Registrar usuario nuevo
2. - [ ] Login con usuario nuevo
3. - [ ] Listar espacios disponibles
4. - [ ] Conectar vía WebSocket al espacio 1
5. - [ ] Verificar que aparece en lista de avatares
6. - [ ] Mover avatar
7. - [ ] Otros usuarios ven el movimiento
8. - [ ] Leave del espacio
9. - [ ] Avatar marcado como inactive

### Escenario 2: Múltiples Usuarios - Proximidad

1. - [ ] Usuario 1 entra en (10, 10)
2. - [ ] Usuario 2 entra en (12, 12)
3. - [ ] Ambos reciben proximity_update indicando que están cerca
4. - [ ] Usuario 2 se mueve a (50, 50)
5. - [ ] Ambos reciben proximity_update indicando que ya NO están cerca
6. - [ ] Usuario 1 verifica con get_nearby_users que lista está vacía

### Escenario 3: Capacidad Máxima

1. - [ ] Crear espacio con max_occupancy: 2
2. - [ ] Verificar occupancy: 0/2
3. - [ ] Usuario 1 entra
4. - [ ] Verificar occupancy: 1/2
5. - [ ] Usuario 2 entra
6. - [ ] Verificar occupancy: 2/2, at_capacity: true
7. - [ ] Usuario 3 intenta entrar → Error
8. - [ ] Usuario 1 sale
9. - [ ] Verificar occupancy: 1/2, at_capacity: false
10. - [ ] Usuario 3 puede entrar ahora

### Escenario 4: Persistencia

1. - [ ] Usuario entra a espacio en posición (25, 25)
2. - [ ] Cerrar navegador (disconnect)
3. - [ ] Volver a entrar
4. - [ ] Verificar que avatar se reactiva
5. - [ ] Verificar posición anterior

---

## Performance y Stress Testing

### Múltiples Usuarios Simultáneos

- [ ] 10 usuarios en un espacio
- [ ] 25 usuarios en un espacio
- [ ] 50 usuarios en un espacio
- [ ] Verificar que proximity_update no se dispara excesivamente
- [ ] Verificar que movimientos se broadcastean correctamente
- [ ] Sin memory leaks

### Múltiples Espacios

- [ ] Crear 10 espacios
- [ ] Usuarios en espacios diferentes no reciben eventos entre sí
- [ ] Cada espacio mantiene su propio estado

---

## LiveDashboard

Verificaciones en http://localhost:4000/dev/dashboard:

- [ ] Ver métricas de requests
- [ ] Ver procesos activos
- [ ] Ver channels activos
- [ ] Ver memoria y CPU usage
- [ ] No hay procesos muertos o en crash

---

## Resumen

**Total de checks:** ~150+

**Secciones:**
- ✅ Setup Inicial (5 checks)
- ✅ API REST - Usuarios (20+ checks)
- ✅ API REST - Espacios (30+ checks)
- ✅ WebSockets - Conexión (10+ checks)
- ✅ WebSockets - Eventos (15+ checks)
- ✅ WebSockets - Acciones (20+ checks)
- ✅ Phoenix Presence (5 checks)
- ✅ Lógica de Negocio (20+ checks)
- ✅ Tests Automatizados (5 checks)
- ✅ Escenarios de Integración (4 escenarios)
- ✅ Performance (10+ checks)
- ✅ LiveDashboard (5 checks)

---

## Próximos Pasos

Una vez completado este checklist:

1. ✅ Documentar cualquier bug encontrado
2. ✅ Crear issues para features faltantes
3. ✅ Comenzar desarrollo del frontend
4. ✅ Planning de features adicionales (ver README.md)

---

**Happy Testing! 🚀**
