# PplWork

Un clon de Gather.town construido con Elixir y Phoenix Framework. Plataforma de espacios virtuales 2D donde múltiples usuarios pueden interactuar en tiempo real.

## Características

- **Espacios Virtuales 2D**: Crea y gestiona espacios personalizables con dimensiones configurables
- **Movimiento en Tiempo Real**: Sistema de WebSockets para actualización instantánea de posiciones
- **Sistema de Avatares**: Representación de usuarios con posición y dirección
- **Detección de Proximidad**: Algoritmo para identificar usuarios cercanos en el espacio
- **Phoenix Presence**: Tracking automático de usuarios conectados
- **Autenticación de Usuarios**: Sistema completo de registro y login con bcrypt
- **API REST**: Endpoints para gestión de usuarios y espacios
- **Control de Capacidad**: Límites configurables de ocupación por espacio

## Stack Tecnológico

- **Elixir 1.15+** - Lenguaje de programación funcional
- **Phoenix 1.8** - Framework web
- **Phoenix Channels** - WebSockets para comunicación en tiempo real
- **Phoenix Presence** - Sistema de tracking de presencia
- **Ecto 3.13** - ORM para base de datos
- **PostgreSQL** - Base de datos relacional
- **Bcrypt** - Hashing de contraseñas

## Arquitectura

### Contextos (Bounded Contexts)

- **Accounts** - Gestión de usuarios y autenticación
- **Spaces** - CRUD de espacios virtuales
- **World** - Lógica de avatares, movimiento y proximidad

### Schemas

- **User** - Usuarios del sistema
- **Space** - Espacios virtuales 2D
- **Avatar** - Posición de usuario en un espacio

### Canales (WebSocket)

- **SpaceChannel** - Comunicación en tiempo real dentro de un espacio
  - Eventos: `user_joined`, `user_moved`, `user_left`, `proximity_update`

## Setup

### Prerequisitos

- Elixir 1.15 o superior
- Erlang/OTP 26 o superior
- **Docker y Docker Compose** (recomendado) O PostgreSQL 14+ instalado localmente
- Node.js (para assets)

### Instalación Rápida con Docker (Recomendado)

La forma más fácil de empezar es usando Docker Compose:

```bash
# Ver comandos disponibles
make help

# Setup completo en un comando
make setup

# Iniciar el servidor
make server
```

Esto iniciará PostgreSQL en Docker, instalará dependencias, creará y migrará la base de datos.

### Instalación Manual

Si prefieres no usar Docker:

1. **Instalar dependencias:**
```bash
mix deps.get
```

2. **Iniciar PostgreSQL:**
   - Con Docker: `make db-up`
   - Con instalación local: asegúrate de que PostgreSQL esté corriendo

3. **Crear y migrar la base de datos:**
```bash
mix ecto.create
mix ecto.migrate
```

4. **Iniciar el servidor Phoenix:**
```bash
mix phx.server
# O con IEx
iex -S mix phx.server
```

El servidor estará disponible en [`localhost:4000`](http://localhost:4000)

### Comandos Make Útiles

```bash
make db-up       # Iniciar PostgreSQL
make db-down     # Detener PostgreSQL
make db-logs     # Ver logs de PostgreSQL
make db-shell    # Abrir shell de PostgreSQL
make db-reset    # Resetear base de datos (⚠️ borra datos)
make test        # Ejecutar tests
make server      # Iniciar Phoenix server
```

## API REST

### Usuarios

**Registrar usuario:**
```bash
POST /api/users/register
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "username": "johndoe",
    "password": "Password123"
  }
}
```

**Login:**
```bash
POST /api/users/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123"
}
```

### Espacios

**Listar espacios públicos:**
```bash
GET /api/spaces
```

**Crear espacio:**
```bash
POST /api/spaces
Content-Type: application/json

{
  "space": {
    "name": "Mi Espacio",
    "width": 100,
    "height": 100,
    "description": "Un espacio de trabajo virtual",
    "is_public": true,
    "max_occupancy": 50
  }
}
```

**Ver ocupación del espacio:**
```bash
GET /api/spaces/:id/occupancy
```

## WebSocket API

### Conectar a un espacio

```javascript
import {Socket} from "phoenix"

let socket = new Socket("/socket")
socket.connect()

let channel = socket.channel("space:1", {
  user_id: 123,
  x: 50,
  y: 50
})

channel.join()
  .receive("ok", resp => { console.log("Joined space", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
```

### Eventos del canal

**Mover avatar:**
```javascript
channel.push("move", {x: 25, y: 30, direction: "up"})
  .receive("ok", (avatar) => console.log("Moved", avatar))
```

**Escuchar movimientos de otros usuarios:**
```javascript
channel.on("user_moved", payload => {
  console.log("User moved:", payload.avatar)
})
```

**Escuchar actualizaciones de proximidad:**
```javascript
channel.on("proximity_update", payload => {
  console.log("Nearby users:", payload.proximity_groups)
})
```

**Obtener usuarios cercanos:**
```javascript
channel.push("get_nearby_users", {radius: 5.0})
  .receive("ok", (resp) => console.log("Nearby:", resp.nearby_users))
```

## Testing

### Tests Automatizados

Ejecutar todos los tests:
```bash
mix test
```

Tests por contexto:
```bash
mix test test/ppl_work/accounts_test.exs
mix test test/ppl_work/spaces_test.exs
mix test test/ppl_work/world_test.exs
```

### Testing Manual

**Poblar con datos de prueba:**
```bash
mix run priv/repo/seeds.exs
```

Esto crea 5 usuarios y 4 espacios de ejemplo (ver output para IDs).

**Script automatizado de API:**
```bash
./test_api.sh
```

Prueba automáticamente todos los endpoints REST.

**Testing de WebSockets:**

1. Abrir http://localhost:4000 en el navegador
2. Abrir consola (F12)
3. Copiar contenido de `assets/js/websocket_test.js` en la consola
4. Ejecutar: `testWebSocket(1, 1)`

### Recursos de Testing

- 📖 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Guía completa paso a paso
- 📖 **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Checklist sistemático (~150 checks)
- 📖 **[HTTP_CLIENT_EXAMPLES.md](HTTP_CLIENT_EXAMPLES.md)** - Ejemplos con curl, HTTPie, JavaScript, Python
- 🎯 **[test_api.sh](test_api.sh)** - Script bash automatizado
- 🌐 **[websocket_test.js](assets/js/websocket_test.js)** - Testing de WebSockets en browser

## Estructura del Proyecto

```
lib/
├── ppl_work/                 # Lógica de negocio
│   ├── accounts/             # Contexto de usuarios
│   │   └── user.ex
│   ├── spaces/               # Contexto de espacios
│   │   └── space.ex
│   ├── world/                # Contexto de mundo virtual
│   │   └── avatar.ex
│   ├── accounts.ex
│   ├── spaces.ex
│   └── world.ex
├── ppl_work_web/             # Capa web
│   ├── channels/             # WebSocket channels
│   │   ├── space_channel.ex
│   │   └── user_socket.ex
│   ├── controllers/          # API REST
│   │   ├── user_controller.ex
│   │   ├── space_controller.ex
│   │   └── ...
│   ├── presence.ex           # Phoenix Presence
│   └── endpoint.ex
priv/repo/migrations/         # Migraciones de BD
test/                         # Tests
```

## Próximos Pasos

Algunas ideas para expandir el MVP:

- [ ] Sistema de salas privadas con invitaciones
- [ ] Chat de texto integrado
- [ ] Integración de video/audio (WebRTC)
- [ ] Objetos interactivos en el espacio
- [ ] Zonas con diferentes propiedades (salas de reunión, etc.)
- [ ] Persistencia de estado del espacio
- [ ] Sistema de permisos y roles
- [ ] Edición visual de espacios
- [ ] Métricas y analytics

## Recursos

* [Phoenix Framework](https://www.phoenixframework.org/)
* [Elixir Docs](https://hexdocs.pm/elixir/)
* [Phoenix Channels Guide](https://hexdocs.pm/phoenix/channels.html)
* [Phoenix Presence Guide](https://hexdocs.pm/phoenix/presence.html)
* [Ecto Documentation](https://hexdocs.pm/ecto/)
