# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PplWork is a Gather.town clone built with Elixir and Phoenix Framework. It's a real-time 2D virtual space platform where multiple users can interact simultaneously through WebSockets, with proximity detection, avatar movement, and presence tracking.

## Common Development Commands

### Setup and Database
```bash
make setup          # Complete setup: start DB, install deps, create & migrate DB
make db-up          # Start PostgreSQL in Docker
make db-down        # Stop PostgreSQL
make db-reset       # Reset database (destroys all data)
make db-shell       # Open PostgreSQL shell
```

### Development Workflow
```bash
make server         # Start Phoenix server (mix phx.server)
make iex            # Start Phoenix server in IEx (iex -S mix phx.server)
make test           # Run all tests
mix test test/path/to/specific_test.exs  # Run specific test file
```

### Database Operations
```bash
mix ecto.create     # Create database
mix ecto.migrate    # Run migrations
mix ecto.reset      # Drop, create, migrate, and seed
mix run priv/repo/seeds.exs  # Seed database with test data
```

### Testing
```bash
./test_api.sh       # Run automated API testing script
mix test            # Run automated test suite
```

For manual WebSocket testing: Open http://localhost:4000, paste content from `assets/js/websocket_test.js` in browser console, then run `testWebSocket(1, 1)`.

## Architecture Overview

### Bounded Contexts (Phoenix Contexts)

The application follows Phoenix's bounded context pattern with three main domains:

1. **Accounts** (`lib/ppl_work/accounts.ex`)
   - Manages user authentication and registration
   - Uses bcrypt for password hashing
   - Schema: `User` (email, username, password_hash)
   - Validations: email format, unique username/email, password strength

2. **Spaces** (`lib/ppl_work/spaces.ex`)
   - CRUD operations for virtual 2D spaces
   - Schema: `Space` (name, width, height, max_occupancy, is_public)
   - Tracks occupancy and enforces capacity limits
   - Default dimensions: 50x50, max 50 users

3. **World** (`lib/ppl_work/world.ex`)
   - Core business logic for avatars, movement, and proximity
   - Schema: `Avatar` (x, y, direction, is_active, user_id, space_id)
   - Manages avatar lifecycle: join_space, move_avatar, leave_space
   - Proximity detection algorithm using Euclidean distance
   - **CRITICAL**: Avatar functions must preload `:user` association before returning

### Data Model Relationships

```
User (1) -----> (*) Avatar (*) <----- (1) Space
```

- A User can have multiple Avatars (one per Space)
- An Avatar belongs to one User and one Space
- A Space contains multiple Avatars
- Unique constraint: one Avatar per User per Space

### WebSocket Real-Time Communication

**Channel**: `SpaceChannel` (`lib/ppl_work_web/channels/space_channel.ex`)
- Topic pattern: `"space:{space_id}"`
- Join params: `{user_id, x, y, direction}`

**Lifecycle**:
1. User joins channel → `join/3` validates space capacity → creates/activates avatar
2. `:after_join` callback → tracks Presence → broadcasts `user_joined` event
3. Movement: client sends `"move"` → server validates → broadcasts `user_moved`
4. Proximity: triggered after movement → calculates nearby users → broadcasts `proximity_update`
5. Disconnect: `terminate/2` → deactivates avatar → broadcasts `user_left`

**Events**:
- Incoming: `"move"`, `"get_state"`, `"get_nearby_users"`
- Outgoing: `user_joined`, `user_moved`, `user_left`, `proximity_update`

**Phoenix Presence**: Automatically tracks connected users per space with heartbeat mechanism.

## Critical Code Patterns

### 1. Ecto Preloading for Avatars

**CRITICAL**: The `serialize_avatar/1` function in `SpaceChannel` accesses `avatar.user.username`. Any function in the `World` context that returns an avatar MUST preload the `:user` association, otherwise it will crash with `Ecto.Association.NotLoaded`.

**Required pattern**:
```elixir
# In World context functions that return avatars:
case result do
  {:ok, avatar} -> {:ok, Repo.preload(avatar, :user)}
  error -> error
end
```

**Functions that MUST preload :user**:
- `World.get_avatar!/1` - Already preloads
- `World.create_avatar/3` - Preloads before returning
- `World.activate_avatar/2` - Preloads before returning
- `World.list_avatars_in_space/1` - Already preloads
- `World.find_nearby_avatars/4` - Already preloads

**Why**: SpaceChannel serializes avatars for WebSocket broadcasts. Without preloaded user, serialization crashes when accessing `avatar.user.username`.

### 2. Movement and Boundary Validation

Movement is validated in `World.move_avatar/2`:
- Fetches space to get boundaries (width, height)
- Clamps coordinates: `x ∈ [0, space.width]`, `y ∈ [0, space.height]`
- Validates direction: must be "up", "down", "left", or "right"
- Updates avatar position atomically via Ecto changeset

### 3. Proximity Detection Algorithm

`World.get_proximity_groups/2`:
- Default radius: 5.0 units
- Uses Euclidean distance: `sqrt((x2-x1)² + (y2-y1)²)`
- Returns map: `%{avatar_id => [nearby_avatar_ids]}`
- Only considers active avatars
- Triggered automatically after movement in SpaceChannel

### 4. Space Capacity Management

Before allowing user to join:
1. `Spaces.space_at_capacity?/1` checks current occupancy
2. Counts active avatars in space
3. Compares against `space.max_occupancy`
4. Returns `{:error, :space_at_capacity}` if full

### 5. Avatar Lifecycle States

Avatars use `is_active` boolean instead of deletion:
- Active: User is connected to space
- Inactive: User disconnected but avatar persists in DB
- On re-join: Reactivates existing avatar instead of creating new one
- Benefits: Preserves position history, faster re-joins

## Database Migrations

Migration order (chronological):
1. `create_users` - Users table with email/username unique indexes
2. `create_spaces` - Spaces table with dimensions and capacity
3. `create_avatars` - Avatars table with foreign keys, unique index on [user_id, space_id]

When adding migrations:
- Always include `up` and `down` functions
- Add indexes for foreign keys and frequently queried fields
- Use constraints for data integrity (unique, foreign key)

## Testing Strategy

The project has comprehensive testing at multiple levels:

**Automated Tests** (`mix test`):
- Context tests: `test/ppl_work/accounts_test.exs`, `spaces_test.exs`, `world_test.exs`
- Tests use `PplWork.DataCase` for DB cleanup between tests
- Factory pattern in `test/support/fixtures/` for test data

**Manual API Testing**:
- Script: `./test_api.sh` - Automated REST API testing
- Covers: user registration, login, space CRUD, validations, occupancy

**Manual WebSocket Testing**:
- Client: `assets/js/websocket_test.js`
- Browser console usage: `testWebSocket(user_id, space_id)`
- Tests: join, movement, proximity, multiple users

**Test Database**:
- Seeds: `priv/repo/seeds.exs` creates 5 users + 4 spaces
- Test env: Auto-creates/migrates in `mix test`
- Reset: `mix ecto.reset` to start fresh

## API Structure

### REST API (`/api`)
- User registration: `POST /api/users/register`
- User login: `POST /api/users/login`
- Spaces CRUD: `GET|POST|PUT|DELETE /api/spaces/:id`
- Space occupancy: `GET /api/spaces/:id/occupancy`

### WebSocket API (`/socket`)
- Connect: `socket.channel("space:1", {user_id: 123, x: 50, y: 50})`
- Push events: `channel.push("move", {x, y, direction})`
- Listen: `channel.on("user_moved", callback)`

## Development Notes

### Code Style
- Project uses standard Elixir formatting: `mix format`
- Documentation: `@moduledoc` and `@doc` with examples
- Changesets: Separate changesets for different operations (create, update, movement, status)

### Configuration
- Development: Uses Docker Compose for PostgreSQL (see `.env.docker`)
- Database credentials in `config/dev.exs`
- WebSocket endpoint: `/socket` configured in `lib/ppl_work_web/endpoint.ex`
- PubSub: Uses Phoenix.PubSub for Presence and broadcasts

### Important Files
- Router: `lib/ppl_work_web/router.ex` - Defines all HTTP routes
- UserSocket: `lib/ppl_work_web/channels/user_socket.ex` - WebSocket connection handler
- Presence: `lib/ppl_work_web/presence.ex` - Phoenix Presence implementation
- Application: `lib/ppl_work/application.ex` - OTP supervision tree

### Common Gotchas
1. **Preload associations**: Always preload when serializing for JSON/WebSocket
2. **Async broadcast**: Use `broadcast!/3` not `broadcast/3` to raise on errors
3. **Presence tracking**: Must call `Presence.track/3` in `:after_join` callback
4. **Capacity checks**: Validate before creating avatar, not after
5. **Position clamping**: Server-side validation prevents out-of-bounds movement
