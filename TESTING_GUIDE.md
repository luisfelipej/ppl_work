# 🧪 Guía Completa de Testing - PplWork Backend

Esta guía te mostrará cómo probar todas las funcionalidades del backend de PplWork.

## Tabla de Contenidos

1. [Setup Inicial](#setup-inicial)
2. [Testing de API REST](#testing-de-api-rest)
3. [Testing de WebSockets](#testing-de-websockets)
4. [Testing de Presence](#testing-de-presence)
5. [Escenarios de Integración](#escenarios-de-integración)
6. [Herramientas Útiles](#herramientas-útiles)

---

## Setup Inicial

### 1. Iniciar la Aplicación

```bash
# Iniciar PostgreSQL
make db-up

# Crear y migrar BD (primera vez)
mix ecto.create
mix ecto.migrate

# Poblar con datos de prueba
mix run priv/repo/seeds.exs

# Iniciar el servidor
make server
```

Deberías ver el output de seeds con los IDs de usuarios y espacios creados.

### 2. Verificar que el Servidor Está Corriendo

```bash
curl http://localhost:4000
```

Debería devolver el HTML de la página home de Phoenix.

---

## Testing de API REST

### 1. Registro de Usuarios

**Crear un nuevo usuario:**

```bash
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "username": "testuser",
      "password": "Password123"
    }
  }'
```

**Respuesta esperada:**
```json
{
  "data": {
    "id": 6,
    "email": "test@example.com",
    "username": "testuser",
    "inserted_at": "2025-10-04T03:30:00Z",
    "updated_at": "2025-10-04T03:30:00Z"
  }
}
```

**Probar validaciones (debería fallar):**

```bash
# Email inválido
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "invalid-email",
      "username": "test",
      "password": "Password123"
    }
  }'

# Password muy corta
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test2@example.com",
      "username": "test2",
      "password": "short"
    }
  }'

# Username muy corto
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test3@example.com",
      "username": "ab",
      "password": "Password123"
    }
  }'
```

### 2. Login de Usuarios

**Login exitoso:**

```bash
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@pplwork.com",
    "password": "Password123"
  }'
```

**Respuesta esperada:**
```json
{
  "data": {
    "id": 1,
    "email": "alice@pplwork.com",
    "username": "alice",
    "inserted_at": "...",
    "updated_at": "..."
  }
}
```

**Login fallido (contraseña incorrecta):**

```bash
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@pplwork.com",
    "password": "WrongPassword"
  }'
```

**Respuesta esperada:**
```json
{
  "error": "Invalid email or password"
}
```

### 3. Ver Usuario

```bash
# Reemplaza :id con un ID real de usuario
curl http://localhost:4000/api/users/1
```

### 4. Listar Espacios Públicos

```bash
curl http://localhost:4000/api/spaces | jq
```

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Oficina Virtual",
      "width": 100,
      "height": 100,
      "description": "Espacio principal de trabajo colaborativo",
      "is_public": true,
      "max_occupancy": 50,
      "inserted_at": "...",
      "updated_at": "..."
    },
    ...
  ]
}
```

### 5. Crear un Espacio

```bash
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Mi Espacio de Prueba",
      "width": 60,
      "height": 60,
      "description": "Espacio creado para testing",
      "is_public": true,
      "max_occupancy": 20
    }
  }' | jq
```

### 6. Ver un Espacio Específico

```bash
# Reemplaza 1 con un ID real
curl http://localhost:4000/api/spaces/1 | jq
```

### 7. Actualizar un Espacio

```bash
curl -X PUT http://localhost:4000/api/spaces/1 \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Oficina Virtual Actualizada",
      "max_occupancy": 75
    }
  }' | jq
```

### 8. Ver Ocupación de un Espacio

```bash
curl http://localhost:4000/api/spaces/1/occupancy | jq
```

**Respuesta esperada:**
```json
{
  "space_id": "1",
  "current_occupancy": 0,
  "max_occupancy": 50,
  "at_capacity": false
}
```

### 9. Eliminar un Espacio

```bash
curl -X DELETE http://localhost:4000/api/spaces/1
```

---

## Testing de WebSockets

### Preparación

1. Asegúrate de que el servidor esté corriendo: `make server`
2. Abre tu navegador en `http://localhost:4000`
3. Abre la consola del navegador (F12 o Cmd+Opt+J)

### Script de Testing Básico

Copia y pega esto en la consola del navegador:

```javascript
// 1. Conectar al socket
const socket = new Phoenix.Socket("/socket")
socket.connect()
console.log("✅ Socket connected")

// 2. Configurar event listeners ANTES de unirse al canal
const spaceId = 1  // ID de un espacio existente
const userId = 1   // ID de un usuario existente

const channel = socket.channel(`space:${spaceId}`, {
  user_id: userId,
  x: 50,
  y: 50
})

// 3. Escuchar eventos
channel.on("user_joined", payload => {
  console.log("👋 User joined:", payload)
})

channel.on("user_moved", payload => {
  console.log("🏃 User moved:", payload)
})

channel.on("user_left", payload => {
  console.log("👋 User left:", payload)
})

channel.on("proximity_update", payload => {
  console.log("📍 Proximity update:", payload)
})

// 4. Unirse al canal
channel.join()
  .receive("ok", resp => {
    console.log("✅ Joined space successfully!", resp)
    console.log("Current avatars:", resp.avatars)
    console.log("Proximity groups:", resp.proximity_groups)
  })
  .receive("error", resp => {
    console.error("❌ Unable to join", resp)
  })

// 5. Guardar channel en window para usar después
window.testChannel = channel
```

### Comandos para Probar

Una vez que te hayas unido al canal, prueba estos comandos:

**1. Mover tu avatar:**

```javascript
testChannel.push("move", {x: 25, y: 30, direction: "up"})
  .receive("ok", resp => console.log("✅ Moved to:", resp))
  .receive("error", resp => console.log("❌ Error:", resp))
```

**2. Obtener usuarios cercanos:**

```javascript
testChannel.push("get_nearby_users", {radius: 10.0})
  .receive("ok", resp => console.log("Nearby users:", resp.nearby_users))
```

**3. Obtener estado actual del espacio:**

```javascript
testChannel.push("get_state", {})
  .receive("ok", resp => {
    console.log("Space state:", resp)
    console.log("Total avatars:", resp.avatars.length)
  })
```

**4. Moverte a diferentes posiciones:**

```javascript
// Mover arriba
testChannel.push("move", {x: 50, y: 40, direction: "up"})

// Mover a la derecha
testChannel.push("move", {x: 60, y: 50, direction: "right"})

// Mover abajo
testChannel.push("move", {x: 50, y: 60, direction: "down"})

// Mover a la izquierda
testChannel.push("move", {x: 40, y: 50, direction: "left"})
```

**5. Salir del espacio:**

```javascript
testChannel.leave()
  .receive("ok", () => console.log("Left the space"))
```

### Testing con Múltiples Usuarios

Para probar interacciones entre usuarios:

1. Abre 2-3 ventanas del navegador en modo incógnito
2. En cada ventana, abre la consola
3. Conéctate con diferentes user_id en cada ventana
4. Mueve los avatares para ver los eventos en tiempo real

**Ventana 1 (Alice - user_id: 1):**
```javascript
const socket1 = new Phoenix.Socket("/socket")
socket1.connect()

const channel1 = socket1.channel("space:1", {
  user_id: 1,
  x: 10,
  y: 10
})

channel1.on("user_joined", p => console.log("Alice ve: User joined", p))
channel1.on("user_moved", p => console.log("Alice ve: User moved", p))

channel1.join()
  .receive("ok", resp => console.log("Alice joined!", resp))

window.alice = channel1
```

**Ventana 2 (Bob - user_id: 2):**
```javascript
const socket2 = new Phoenix.Socket("/socket")
socket2.connect()

const channel2 = socket2.channel("space:1", {
  user_id: 2,
  x: 15,
  y: 15
})

channel2.on("user_joined", p => console.log("Bob ve: User joined", p))
channel2.on("user_moved", p => console.log("Bob ve: User moved", p))

channel2.join()
  .receive("ok", resp => console.log("Bob joined!", resp))

window.bob = channel2
```

**Ahora en ventana de Alice:**
```javascript
// Alice se mueve, Bob debería ver el evento
alice.push("move", {x: 12, y: 12, direction: "right"})
```

**En ventana de Bob deberías ver:**
```
Bob ve: User moved {user_id: 1, avatar: {...}}
```

---

## Testing de Presence

Phoenix Presence trackea automáticamente quién está conectado.

**En la consola del navegador:**

```javascript
// Después de unirte a un canal
testChannel.on("presence_state", state => {
  console.log("Initial presence state:", state)
})

testChannel.on("presence_diff", diff => {
  console.log("Presence changed:", diff)
  console.log("Joins:", diff.joins)
  console.log("Leaves:", diff.leaves)
})
```

**Para ver el estado actual de presence:**

```javascript
// Esto está disponible del lado del servidor
// Puedes verificarlo en IEx:
// iex> PplWorkWeb.Presence.list("space:1")
```

---

## Escenarios de Integración

### Escenario 1: Flujo Completo de Usuario Nuevo

```bash
# 1. Registrar usuario
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newuser@test.com",
      "username": "newuser",
      "password": "Password123"
    }
  }' | jq '.data.id'

# Guarda el ID que te devuelve (ej: 6)

# 2. Login
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@test.com",
    "password": "Password123"
  }' | jq

# 3. Listar espacios disponibles
curl http://localhost:4000/api/spaces | jq

# 4. Conectarse a un espacio vía WebSocket (en browser console)
const socket = new Phoenix.Socket("/socket")
socket.connect()

const channel = socket.channel("space:1", {
  user_id: 6,  // El ID de newuser
  x: 25,
  y: 25
})

channel.join()
  .receive("ok", resp => console.log("Joined!", resp))

# 5. Moverse por el espacio
channel.push("move", {x: 30, y: 35, direction: "right"})
```

### Escenario 2: Testing de Límites de Capacidad

```bash
# 1. Crear un espacio con capacidad máxima de 2
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Espacio Pequeño",
      "width": 30,
      "height": 30,
      "max_occupancy": 2
    }
  }' | jq '.data.id'

# Guarda el space_id (ej: 5)

# 2. En Browser Console - Ventana 1 (User 1)
const ch1 = new Phoenix.Socket("/socket").connect()
  .channel("space:5", {user_id: 1, x: 10, y: 10})
ch1.join().receive("ok", () => console.log("User 1 joined"))

# 3. En Browser Console - Ventana 2 (User 2)
const ch2 = new Phoenix.Socket("/socket").connect()
  .channel("space:5", {user_id: 2, x: 15, y: 15})
ch2.join().receive("ok", () => console.log("User 2 joined"))

# 4. En Browser Console - Ventana 3 (User 3 - debería fallar)
const ch3 = new Phoenix.Socket("/socket").connect()
  .channel("space:5", {user_id: 3, x: 20, y: 20})
ch3.join()
  .receive("error", resp => console.log("Expected error:", resp))
  // Debería ver: {reason: "Space is at maximum capacity"}

# 5. Verificar ocupancy
curl http://localhost:4000/api/spaces/5/occupancy | jq
# Debería mostrar: current_occupancy: 2, at_capacity: true
```

### Escenario 3: Testing de Proximidad

```javascript
// En browser console
const socket = new Phoenix.Socket("/socket")
socket.connect()

// User 1 en posición (10, 10)
const user1 = socket.channel("space:1", {
  user_id: 1,
  x: 10,
  y: 10
})

user1.on("proximity_update", payload => {
  console.log("User 1 proximity:", payload.proximity_groups)
})

user1.join().receive("ok", () => console.log("User 1 joined"))

// Abre otra ventana/tab para User 2

// User 2 en posición (12, 12) - cerca de User 1
const user2 = socket.channel("space:1", {
  user_id: 2,
  x: 12,
  y: 12
})

user2.on("proximity_update", payload => {
  console.log("User 2 proximity:", payload.proximity_groups)
})

user2.join().receive("ok", () => console.log("User 2 joined"))

// Deberías ver que ambos usuarios detectan proximidad
// porque la distancia entre (10,10) y (12,12) es ~2.83
// que es menor al radio por defecto de 5.0

// Ahora mueve User 2 lejos
user2.push("move", {x: 50, y: 50, direction: "right"})

// Deberías ver un proximity_update indicando que ya no están cerca
```

---

## Herramientas Útiles

### Phoenix LiveDashboard

Visita http://localhost:4000/dev/dashboard para ver:
- Métricas en tiempo real
- Procesos activos
- Memoria y CPU
- Channels activos
- PubSub subscribers

### IEx (Interactive Elixir)

Inicia el servidor en modo interactivo:

```bash
make iex
```

**Comandos útiles en IEx:**

```elixir
# Ver usuarios conectados a un espacio
PplWorkWeb.Presence.list("space:1")

# Listar todos los avatares en un espacio
PplWork.World.list_avatars_in_space(1)

# Ver grupos de proximidad
PplWork.World.get_proximity_groups(1, 5.0)

# Calcular distancia entre dos puntos
PplWork.World.calculate_distance(10, 10, 15, 15)

# Crear un usuario manualmente
PplWork.Accounts.register_user(%{
  email: "manual@test.com",
  username: "manual",
  password: "Password123"
})

# Ver todos los usuarios
PplWork.Accounts.list_users()

# Ver todos los espacios
PplWork.Spaces.list_spaces()
```

### Script Automatizado

Ejecuta el script de testing automatizado:

```bash
chmod +x test_api.sh
./test_api.sh
```

### HTTPie (Alternativa a curl)

Si prefieres HTTPie (más legible):

```bash
# Instalar
brew install httpie  # macOS
# o
apt install httpie   # Linux

# Registrar usuario
http POST localhost:4000/api/users/register \
  user:='{"email": "test@example.com", "username": "test", "password": "Password123"}'

# Login
http POST localhost:4000/api/users/login \
  email=alice@pplwork.com password=Password123

# Listar espacios
http localhost:4000/api/spaces
```

---

## Checklist de Testing Completo

Ver [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) para un checklist sistemático de todas las funcionalidades.

---

## Troubleshooting

### "Phoenix is not defined" en Browser Console

Si al ejecutar el script de WebSocket obtienes:
```
Uncaught ReferenceError: Phoenix is not defined
```

**Solución:**
1. Asegúrate de que el servidor esté corriendo (`make server`)
2. **Recarga la página en el navegador** (Cmd+R o F5)
3. Verifica que `window.Phoenix` existe:
   ```javascript
   console.log(window.Phoenix)  // Debe mostrar {Socket: ƒ}
   ```

El objeto `Phoenix` solo está disponible en modo desarrollo y se expone globalmente al cargar la página.

### "Connection refused" en WebSocket

```bash
# Verificar que el servidor está corriendo
curl http://localhost:4000

# Ver logs del servidor
# En la terminal donde corrió `make server`
```

### "Space not found" al unirse a un canal

```bash
# Listar espacios disponibles
curl http://localhost:4000/api/spaces | jq

# Usar un space_id válido
```

### "User not found"

```bash
# Crear el usuario primero
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "test@test.com", "username": "test", "password": "Password123"}}'
```

### Los eventos de WebSocket no llegan

```javascript
// Asegúrate de configurar listeners ANTES de hacer join()
channel.on("user_moved", payload => console.log(payload))
channel.on("user_joined", payload => console.log(payload))

// LUEGO unirse
channel.join()
```

---

## Próximos Pasos

Una vez que hayas probado todo manualmente:

1. ✅ Ejecutar los tests automatizados: `make test`
2. ✅ Explorar el LiveDashboard: http://localhost:4000/dev/dashboard
3. ✅ Ver [HTTP_CLIENT_EXAMPLES.md](HTTP_CLIENT_EXAMPLES.md) para más ejemplos
4. ✅ Revisar [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) para asegurar cobertura completa

¡Happy Testing! 🚀
