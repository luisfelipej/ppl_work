# Guía Docker - PplWork

Esta guía explica cómo usar Docker para desarrollo local en el proyecto PplWork.

## Inicio Rápido

```bash
# 1. Ver comandos disponibles
make help

# 2. Setup completo (inicia DB + crea esquema)
make setup

# 3. Iniciar el servidor Phoenix
make server
```

¡Listo! Tu aplicación estará corriendo en http://localhost:4000

## Arquitectura Docker

### Servicios

- **PostgreSQL 16 Alpine** - Base de datos principal
  - Puerto: `5432` (configurable)
  - Usuario: `postgres` (configurable)
  - Base de datos: `ppl_work_dev` (configurable)
  - Volume persistente: `postgres_data`

### Archivos de Configuración

```
.
├── docker-compose.yml      # Configuración de servicios
├── .env.docker            # Variables de entorno (commiteado)
├── .env.example           # Ejemplo de variables
└── .env.local            # Sobrescribe .env.docker (git-ignored)
```

## Comandos Make

### Gestión de Base de Datos

```bash
make db-up        # Iniciar PostgreSQL
make db-down      # Detener PostgreSQL
make db-restart   # Reiniciar PostgreSQL
make db-logs      # Ver logs en tiempo real
make db-shell     # Abrir psql shell interactivo
make db-reset     # ⚠️ Destruir y recrear la BD
```

### Desarrollo

```bash
make setup        # Setup inicial completo
make server       # Iniciar Phoenix server
make iex          # Iniciar Phoenix en IEx
make test         # Ejecutar tests
make clean        # Limpiar artefactos de build
```

## Configuración Personalizada

### Variables de Entorno

Para personalizar la configuración, crea un archivo `.env.local`:

```bash
# .env.local
POSTGRES_USER=mi_usuario
POSTGRES_PASSWORD=mi_password_segura
POSTGRES_DB=mi_base_de_datos
POSTGRES_PORT=5433  # Si el 5432 está ocupado
```

Luego reinicia:
```bash
make db-down
make db-up
```

### Conectarse desde el Host

La base de datos está accesible desde tu máquina local:

```bash
# Con psql
psql -h localhost -p 5432 -U postgres -d ppl_work_dev

# Con herramientas GUI
Host: localhost
Port: 5432
User: postgres
Password: postgres
Database: ppl_work_dev
```

### Conectarse desde la aplicación Elixir

La configuración en `config/dev.exs` lee automáticamente las variables de entorno:

```elixir
config :ppl_work, PplWork.Repo,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  database: System.get_env("POSTGRES_DB") || "ppl_work_dev",
  port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432")
```

## Comandos Docker Compose Directos

Si prefieres no usar Make:

```bash
# Iniciar servicios
docker-compose --env-file .env.docker up -d

# Ver logs
docker-compose logs -f postgres

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ borra datos)
docker-compose down -v

# Ver estado de servicios
docker-compose ps

# Ejecutar comando en el contenedor
docker-compose exec postgres psql -U postgres -d ppl_work_dev
```

## Flujo de Trabajo Típico

### Primera vez

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd ppl_work

# 2. Setup completo
make setup

# 3. (Opcional) Poblar con datos de prueba
mix run priv/repo/seeds.exs

# 4. Iniciar el servidor
make server
```

### Día a día

```bash
# Iniciar BD (si no está corriendo)
make db-up

# Iniciar servidor
make server

# En otra terminal, ejecutar tests
make test
```

### Al finalizar

```bash
# Detener PostgreSQL (los datos se mantienen)
make db-down
```

## Volúmenes y Persistencia

### Datos Persistentes

PostgreSQL almacena datos en un volumen de Docker:
- Nombre: `ppl_work_postgres_data`
- Los datos persisten entre reinicios del contenedor
- Solo se eliminan con `docker-compose down -v` o `make db-reset`

### Ver volúmenes

```bash
# Listar volúmenes
docker volume ls | grep ppl_work

# Inspeccionar volumen
docker volume inspect ppl_work_postgres_data
```

### Backup y Restore

```bash
# Backup
docker-compose exec postgres pg_dump -U postgres ppl_work_dev > backup.sql

# Restore
cat backup.sql | docker-compose exec -T postgres psql -U postgres -d ppl_work_dev
```

## Troubleshooting

### Puerto 5432 ya en uso

Si ya tienes PostgreSQL corriendo localmente:

**Opción 1:** Detener PostgreSQL local
```bash
# macOS
brew services stop postgresql

# Linux
sudo systemctl stop postgresql
```

**Opción 2:** Cambiar puerto en `.env.local`
```bash
POSTGRES_PORT=5433
```

### Contenedor no inicia

```bash
# Ver logs de error
make db-logs

# Verificar estado
docker-compose ps

# Recrear contenedor
make db-down
make db-up
```

### Resetear todo

```bash
# Eliminar contenedor y volúmenes
make db-reset

# O manualmente
docker-compose down -v
docker volume rm ppl_work_postgres_data
make db-up
```

### Permisos de conexión

Si hay errores de permisos:

```bash
# Verificar que el usuario/password son correctos
docker-compose exec postgres psql -U postgres

# Ver variables de entorno del contenedor
docker-compose exec postgres env | grep POSTGRES
```

## Health Check

El contenedor de PostgreSQL tiene un health check automático:

```bash
# Ver estado de salud
docker-compose ps

# El estado debe ser "healthy" después de ~10 segundos
```

## Performance

### Aumentar recursos de Docker

Si experimentas lentitud, aumenta recursos en Docker Desktop:
- CPU: mínimo 2 cores
- RAM: mínimo 4GB
- Swap: 1GB

### Pool de conexiones

El pool size está configurado en `config/dev.exs`:
```elixir
pool_size: 10  # Ajusta según necesidad
```

## Múltiples Desarrolladores

Cada desarrollador puede tener su propia configuración:

```bash
# Crear .env.local con configuración personal
cp .env.example .env.local

# Editar según necesidad
vim .env.local

# .env.local es ignorado por git
```

## CI/CD

Para CI/CD, usa las variables de entorno directamente:

```yaml
# .github/workflows/test.yml
services:
  postgres:
    image: postgres:16-alpine
    env:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: ppl_work_test
    ports:
      - 5432:5432
```

## Recursos Adicionales

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Phoenix + Docker Guide](https://hexdocs.pm/phoenix/releases.html#containers)

## Próximos Pasos

Ver [NEXT_STEPS.md](NEXT_STEPS.md) para continuar con el desarrollo.
