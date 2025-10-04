# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PplWork.Repo.insert!(%PplWork.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PplWork.{Accounts, Spaces, Repo}

IO.puts("\n🌱 Starting seeds...\n")

# Clear existing data (optional - comment out if you want to keep existing data)
Repo.delete_all(PplWork.World.Avatar)
Repo.delete_all(PplWork.Spaces.Space)
Repo.delete_all(PplWork.Accounts.User)

IO.puts("🗑️  Cleared existing data\n")

# Create users
IO.puts("👤 Creating users...")

{:ok, alice} = Accounts.register_user(%{
  email: "alice@pplwork.com",
  username: "alice",
  password: "Password123"
})
IO.puts("  ✅ Alice created (ID: #{alice.id})")

{:ok, bob} = Accounts.register_user(%{
  email: "bob@pplwork.com",
  username: "bob",
  password: "Password123"
})
IO.puts("  ✅ Bob created (ID: #{bob.id})")

{:ok, charlie} = Accounts.register_user(%{
  email: "charlie@pplwork.com",
  username: "charlie",
  password: "Password123"
})
IO.puts("  ✅ Charlie created (ID: #{charlie.id})")

{:ok, diana} = Accounts.register_user(%{
  email: "diana@pplwork.com",
  username: "diana",
  password: "Password123"
})
IO.puts("  ✅ Diana created (ID: #{diana.id})")

{:ok, eve} = Accounts.register_user(%{
  email: "eve@pplwork.com",
  username: "eve",
  password: "Password123"
})
IO.puts("  ✅ Eve created (ID: #{eve.id})")

IO.puts("")

# Create spaces
IO.puts("🏢 Creating spaces...")

{:ok, office} = Spaces.create_space(%{
  name: "Oficina Virtual",
  width: 100,
  height: 100,
  description: "Espacio principal de trabajo colaborativo",
  is_public: true,
  max_occupancy: 50
})
IO.puts("  ✅ Oficina Virtual created (ID: #{office.id})")

{:ok, meeting_room} = Spaces.create_space(%{
  name: "Sala de Conferencias",
  width: 50,
  height: 50,
  description: "Para reuniones importantes y presentaciones",
  is_public: true,
  max_occupancy: 25
})
IO.puts("  ✅ Sala de Conferencias created (ID: #{meeting_room.id})")

{:ok, lounge} = Spaces.create_space(%{
  name: "Lounge",
  width: 75,
  height: 75,
  description: "Espacio informal para conversaciones casuales",
  is_public: true,
  max_occupancy: 30
})
IO.puts("  ✅ Lounge created (ID: #{lounge.id})")

{:ok, private_space} = Spaces.create_space(%{
  name: "Sala Privada",
  width: 40,
  height: 40,
  description: "Espacio privado - solo por invitación",
  is_public: false,
  max_occupancy: 10
})
IO.puts("  ✅ Sala Privada created (ID: #{private_space.id})")

IO.puts("")
IO.puts("✨ Seeds completed successfully!\n")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
IO.puts("📊 Summary:")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
IO.puts("")
IO.puts("👥 Users (all with password: Password123):")
IO.puts("   • alice@pplwork.com (ID: #{alice.id})")
IO.puts("   • bob@pplwork.com (ID: #{bob.id})")
IO.puts("   • charlie@pplwork.com (ID: #{charlie.id})")
IO.puts("   • diana@pplwork.com (ID: #{diana.id})")
IO.puts("   • eve@pplwork.com (ID: #{eve.id})")
IO.puts("")
IO.puts("🏢 Spaces:")
IO.puts("   • Oficina Virtual (ID: #{office.id}) - 100x100, max 50 users")
IO.puts("   • Sala de Conferencias (ID: #{meeting_room.id}) - 50x50, max 25 users")
IO.puts("   • Lounge (ID: #{lounge.id}) - 75x75, max 30 users")
IO.puts("   • Sala Privada (ID: #{private_space.id}) - 40x40, max 10 users, PRIVATE")
IO.puts("")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
IO.puts("🚀 Ready to test!")
IO.puts("")
IO.puts("Quick test commands:")
IO.puts("")
IO.puts("# Login as Alice")
IO.puts(~s(curl -X POST http://localhost:4000/api/users/login \\))
IO.puts(~s(  -H "Content-Type: application/json" \\))
IO.puts(~s(  -d '{"email": "alice@pplwork.com", "password": "Password123"}'))
IO.puts("")
IO.puts("# List public spaces")
IO.puts("curl http://localhost:4000/api/spaces")
IO.puts("")
IO.puts("See TESTING_GUIDE.md for complete testing instructions!")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
