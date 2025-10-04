# Próximos Pasos - PplWork

## 1. Iniciar PostgreSQL

### Opción A: Docker Compose (Recomendado) ✅

La forma más fácil es usar Docker Compose. Todo está configurado y listo:

```bash
# Ver todos los comandos disponibles
make help

# Iniciar PostgreSQL
make db-up

# Setup completo (inicia DB, instala deps, crea y migra BD)
make setup
```

**Comandos útiles del Makefile:**
- `make db-up` - Iniciar PostgreSQL
- `make db-down` - Detener PostgreSQL
- `make db-restart` - Reiniciar PostgreSQL
- `make db-logs` - Ver logs de PostgreSQL
- `make db-shell` - Abrir shell de PostgreSQL
- `make db-reset` - Resetear BD (⚠️ borra todos los datos)
- `make setup` - Setup completo del proyecto
- `make server` - Iniciar Phoenix server
- `make test` - Ejecutar tests

Si prefieres comandos docker-compose directos:
```bash
# Iniciar
docker-compose --env-file .env.docker up -d

# Detener
docker-compose down

# Ver logs
docker-compose logs -f postgres
```

### Opción B: PostgreSQL Local

Si prefieres instalación local:

**macOS (con Homebrew):**
```bash
brew services start postgresql@14
```

**Linux:**
```bash
sudo systemctl start postgresql
```

## 2. Configurar la Base de Datos

Si usaste `make setup`, ya está todo configurado. Si no:

```bash
# Crear la base de datos
mix ecto.create

# Ejecutar las migraciones
mix ecto.migrate
```

## 3. Poblar con Datos de Prueba (Opcional)

Puedes crear un archivo de seeds para datos iniciales:

```elixir
# priv/repo/seeds.exs
alias PplWork.{Accounts, Spaces}

# Crear usuarios de prueba
{:ok, user1} = Accounts.register_user(%{
  email: "alice@example.com",
  username: "alice",
  password: "Password123"
})

{:ok, user2} = Accounts.register_user(%{
  email: "bob@example.com",
  username: "bob",
  password: "Password123"
})

# Crear espacios de prueba
{:ok, _space1} = Spaces.create_space(%{
  name: "Oficina Virtual",
  width: 100,
  height: 100,
  description: "Espacio de trabajo colaborativo",
  is_public: true,
  max_occupancy: 50
})

{:ok, _space2} = Spaces.create_space(%{
  name: "Sala de Conferencias",
  width: 50,
  height: 50,
  description: "Para reuniones importantes",
  is_public: true,
  max_occupancy: 25
})

IO.puts "✅ Seeds creados exitosamente!"
```

Luego ejecuta:
```bash
mix run priv/repo/seeds.exs
```

## 4. Iniciar el Servidor

```bash
mix phx.server
```

O en modo interactivo:
```bash
iex -S mix phx.server
```

El servidor estará disponible en http://localhost:4000

## 5. Probar la API

### Registrar un usuario:
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

### Login:
```bash
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123"
  }'
```

### Crear un espacio:
```bash
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Mi Espacio",
      "width": 100,
      "height": 100,
      "description": "Un espacio de prueba",
      "is_public": true,
      "max_occupancy": 50
    }
  }'
```

### Listar espacios:
```bash
curl http://localhost:4000/api/spaces
```

## 6. Probar WebSockets (Desde el Browser Console)

Abre la consola del navegador en http://localhost:4000 y ejecuta:

```javascript
// Conectar al socket
let socket = new Phoenix.Socket("/socket")
socket.connect()

// Unirse a un espacio (reemplaza los IDs con los reales)
let channel = socket.channel("space:1", {
  user_id: 1,  // ID del usuario creado
  x: 50,
  y: 50
})

// Escuchar eventos
channel.on("user_joined", payload => console.log("User joined:", payload))
channel.on("user_moved", payload => console.log("User moved:", payload))
channel.on("proximity_update", payload => console.log("Proximity:", payload))

// Unirse al canal
channel.join()
  .receive("ok", resp => console.log("✅ Joined space successfully!", resp))
  .receive("error", resp => console.log("❌ Unable to join", resp))

// Mover el avatar
channel.push("move", {x: 25, y: 30, direction: "up"})
  .receive("ok", resp => console.log("Moved:", resp))
```

## 7. Ejecutar Tests

```bash
# Todos los tests
mix test

# Tests específicos
mix test test/ppl_work/accounts_test.exs
mix test test/ppl_work/spaces_test.exs
mix test test/ppl_work/world_test.exs

# Con detalles
mix test --trace
```

## 8. Desarrollo del Frontend

Para el frontend, considera:

**Opción 1: Phoenix LiveView**
- Mantente en el ecosistema Phoenix
- Actualización en tiempo real sin JavaScript complejo
- Ideal para aprender Elixir/Phoenix más a fondo

**Opción 2: React/Vue/Svelte**
- Mayor control sobre la UI
- Ecosistema más grande de componentes
- Requiere configurar el cliente Phoenix Socket

**Opción 3: HTML Canvas o Phaser.js**
- Para el renderizado 2D del espacio
- Mejor rendimiento para muchos usuarios
- Más trabajo de implementación

### Ejemplo básico con Canvas:

```html
<!-- assets/js/app.js -->
import {Socket} from "phoenix"

const canvas = document.getElementById('space-canvas')
const ctx = canvas.getContext('2d')

const socket = new Socket("/socket")
socket.connect()

const channel = socket.channel("space:1", {user_id: userId, x: 50, y: 50})

const avatars = {}

channel.on("user_joined", ({user_id, avatar}) => {
  avatars[user_id] = avatar
  render()
})

channel.on("user_moved", ({user_id, avatar}) => {
  avatars[user_id] = avatar
  render()
})

function render() {
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  Object.values(avatars).forEach(avatar => {
    ctx.fillStyle = 'blue'
    ctx.fillRect(avatar.x * 5, avatar.y * 5, 20, 20)
    ctx.fillText(avatar.username, avatar.x * 5, avatar.y * 5 - 5)
  })
}

channel.join()
```

## 9. Siguientes Funcionalidades Sugeridas

### Corto Plazo:
1. **Sistema de tokens JWT** para autenticación en WebSocket
2. **Persistencia de última posición** del avatar
3. **Sistema básico de chat de texto**
4. **Mejora de algoritmo de proximidad** (spatial indexing)

### Mediano Plazo:
5. **Zonas especiales** (áreas de reunión, zonas privadas)
6. **Objetos interactivos** en el espacio
7. **Sistema de permisos** (admin, moderador, usuario)
8. **Notificaciones** cuando alguien se acerca

### Largo Plazo:
9. **Integración WebRTC** para audio/video
10. **Editor visual de espacios**
11. **Sistema de screenshare**
12. **Analytics y métricas**

## 10. Recursos para Aprender Más

- [Programming Phoenix](https://pragprog.com/titles/phoenix14/programming-phoenix-1-4/) - Libro oficial
- [Elixir School](https://elixirschool.com/) - Tutoriales gratuitos
- [Phoenix Channels Deep Dive](https://hexdocs.pm/phoenix/channels.html)
- [Real-time Phoenix](https://pragprog.com/titles/sbsockets/real-time-phoenix/) - Libro sobre tiempo real

## Solución de Problemas

### Error: Connection refused al crear BD

**Con Docker:**
```bash
# Verificar que el contenedor está corriendo
docker-compose ps

# Ver logs para errores
make db-logs

# Reiniciar PostgreSQL
make db-restart
```

**Con instalación local:**
```bash
# Verificar si PostgreSQL está corriendo
psql --version
pg_isready

# Revisar configuración en config/dev.exs
```

### Cambiar configuración de PostgreSQL

Puedes modificar las variables de entorno en `.env.docker`:
```bash
# .env.docker
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=my_database
POSTGRES_PORT=5433  # Si 5432 está en uso
```

Luego reinicia:
```bash
make db-down
make db-up
```

### Error de compilación con Bcrypt
```bash
# En macOS, instalar herramientas de desarrollo
xcode-select --install

# Reinstalar dependencias
mix deps.clean bcrypt_elixir
mix deps.get
mix deps.compile
```

### Tests fallan con timeout
```bash
# Incrementar timeout en config/test.exs
config :ppl_work, PplWork.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  ownership_timeout: 60_000  # Agregar esta línea
```

¡Buena suerte con tu proyecto! 🚀
