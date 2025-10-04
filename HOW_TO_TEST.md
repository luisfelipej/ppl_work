# 🚀 Cómo Probar el Backend de PplWork

Guía rápida para empezar a probar todas las funcionalidades.

## Inicio Rápido (3 minutos)

```bash
# 1. Iniciar base de datos
make db-up

# 2. Crear y migrar BD
mix ecto.create
mix ecto.migrate

# 3. Poblar con datos de prueba
mix run priv/repo/seeds.exs

# 4. Iniciar servidor
make server
```

## Opción 1: Script Automatizado ⚡

La forma más rápida de verificar que todo funciona:

```bash
# Ejecutar tests automatizados
./test_api.sh
```

Este script prueba automáticamente:
- ✅ Registro de usuarios
- ✅ Login
- ✅ CRUD de espacios
- ✅ Validaciones
- ✅ Ocupancy

**Resultado esperado:** Todos los tests en verde 🟢

## Opción 2: Testing Manual de API REST 🔧

### Paso 1: Login como Alice

```bash
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@pplwork.com",
    "password": "Password123"
  }'
```

**Esperado:** Datos de Alice con su ID

### Paso 2: Listar Espacios

```bash
curl http://localhost:4000/api/spaces | jq
```

**Esperado:** Array con 3-4 espacios públicos

### Paso 3: Crear un Espacio

```bash
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Mi Test Space",
      "width": 50,
      "height": 50,
      "max_occupancy": 10
    }
  }' | jq
```

**Esperado:** Espacio creado con su ID

## Opción 3: Testing de WebSockets 🌐

### Paso 1: Abrir Browser

1. Asegúrate de que el servidor esté corriendo (`make server`)
2. Ir a http://localhost:4000
3. Abrir consola (F12 o Cmd+Opt+J)

### Paso 2: Cargar Script de Testing

Copiar y pegar todo el contenido de `assets/js/websocket_test.js` en la consola.

> **Nota:** Si acabas de modificar `app.js`, asegúrate de recargar la página (Cmd+R o F5) para que `Phoenix.Socket` esté disponible globalmente.

### Paso 3: Conectar a un Espacio

```javascript
testWebSocket(1, 1)
```

**Esperado:**
- ✅ Mensaje de bienvenida
- ✅ Lista de avatares actuales
- ✅ Comandos disponibles

### Paso 4: Probar Movimiento

```javascript
testChannel.move(25, 30, "up")
```

**Esperado:**
- ✅ Confirmación de movimiento
- ✅ Nueva posición mostrada

### Paso 5: Ver Usuarios Cercanos

```javascript
testChannel.getNearby(10)
```

**Esperado:** Lista de usuarios dentro de radio 10

### Paso 6: Testing Multi-Usuario

**En otra ventana/tab del navegador:**

```javascript
// Copia el script de nuevo
testWebSocket(1, 2, 20, 20)  // User 2, posición (20, 20)
```

**En la primera ventana, mueve a Alice:**

```javascript
testChannel.move(22, 22)  // Cerca de User 2
```

**Esperado en ambas ventanas:**
- ✅ Evento `user_moved`
- ✅ Evento `proximity_update` indicando que están cerca

## Opción 4: Testing Completo con Checklist 📋

Para testing sistemático de todo:

```bash
# Abrir el checklist
open TESTING_CHECKLIST.md
```

Este checklist incluye ~150 verificaciones de:
- API REST completo
- WebSockets y eventos
- Lógica de negocio
- Validaciones
- Casos edge
- Escenarios de integración

## Datos de Prueba Disponibles

Después de ejecutar seeds, tienes:

**Usuarios** (password: `Password123` para todos):
- alice@pplwork.com (ID: 1)
- bob@pplwork.com (ID: 2)
- charlie@pplwork.com (ID: 3)
- diana@pplwork.com (ID: 4)
- eve@pplwork.com (ID: 5)

**Espacios:**
- Oficina Virtual (ID: 1) - 100x100, max 50
- Sala de Conferencias (ID: 2) - 50x50, max 25
- Lounge (ID: 3) - 75x75, max 30
- Sala Privada (ID: 4) - 40x40, max 10, PRIVATE

## Escenarios de Prueba Recomendados

### Escenario 1: Flujo Básico (2 min)

```bash
# 1. Ejecutar seeds
mix run priv/repo/seeds.exs

# 2. Ejecutar script automatizado
./test_api.sh

# 3. Probar WebSocket básico
# En browser console:
testWebSocket(1, 1)
testChannel.move(25, 25)
testChannel.leave()
```

### Escenario 2: Proximidad (5 min)

1. Abrir 2 ventanas del navegador
2. En ventana 1: `testWebSocket(1, 1, 10, 10)`
3. En ventana 2: `testWebSocket(1, 2, 12, 12)`
4. Observar eventos de proximidad
5. En ventana 2: `testChannel.move(50, 50)`
6. Observar que ya no están cerca

### Escenario 3: Capacidad (3 min)

```bash
# 1. Crear espacio pequeño
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{"space": {"name": "Tiny Room", "width": 20, "height": 20, "max_occupancy": 1}}'

# 2. En browser - User 1 entra
testWebSocket(5, 1)  # Usar el ID del espacio creado

# 3. En otra ventana - User 2 intenta entrar
testWebSocket(5, 2)  # Debería fallar con error de capacidad
```

## Herramientas Útiles

### Phoenix LiveDashboard

```
http://localhost:4000/dev/dashboard
```

Aquí puedes ver:
- Métricas en tiempo real
- Channels activos
- Memoria y CPU
- Procesos

### IEx (Interactive Elixir)

```bash
make iex
```

Comandos útiles:

```elixir
# Ver usuarios conectados
PplWorkWeb.Presence.list("space:1")

# Ver avatares en un espacio
PplWork.World.list_avatars_in_space(1)

# Calcular distancia
PplWork.World.calculate_distance(10, 10, 15, 15)

# Ver grupos de proximidad
PplWork.World.get_proximity_groups(1, 5.0)
```

### cURL con Pretty Print

```bash
# Instalar jq si no lo tienes
brew install jq  # macOS
apt install jq   # Linux

# Usar con cualquier endpoint
curl http://localhost:4000/api/spaces | jq
```

## Troubleshooting

### "Phoenix is not defined" en WebSocket Testing

Si al ejecutar `testWebSocket(1, 1)` obtienes el error:
```
Uncaught ReferenceError: Phoenix is not defined
```

**Solución:**
1. Asegúrate de que el servidor esté corriendo
2. Recarga la página en el navegador (Cmd+R o F5)
3. Verifica en la consola que `window.Phoenix` existe:
   ```javascript
   console.log(window.Phoenix)  // Debe mostrar {Socket: ƒ}
   ```

Si aún no funciona, verifica que `assets/js/app.js` tenga estas líneas al final del bloque de desarrollo:
```javascript
if (process.env.NODE_ENV === "development") {
  // ...
  window.Phoenix = { Socket }
}
```

### "Connection refused"

```bash
# Verificar que el servidor está corriendo
curl http://localhost:4000

# Si no responde, iniciar:
make server
```

### "Database does not exist"

```bash
mix ecto.create
mix ecto.migrate
```

### WebSocket no conecta

```javascript
// Verificar en console:
socket.isConnected()  // debe ser true

// Si es false, reconectar:
socket.connect()
```

### Seeds fallan

```bash
# Resetear BD y volver a correr
mix ecto.reset
mix run priv/repo/seeds.exs
```

## Documentación Completa

Para más detalles, ver:

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Guía paso a paso completa
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Checklist sistemático
- **[HTTP_CLIENT_EXAMPLES.md](HTTP_CLIENT_EXAMPLES.md)** - Ejemplos con diferentes clientes
- **[README.md](README.md)** - Documentación principal

## Siguiente Paso

Una vez que hayas probado todo:

```bash
# Ejecutar tests automatizados
make test
```

¡Todo debería pasar! ✅

---

**¿Listo para empezar?**

```bash
make setup
make server
./test_api.sh
```

🎉 ¡Happy Testing!
