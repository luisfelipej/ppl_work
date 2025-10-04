/**
 * PplWork WebSocket Testing Script
 *
 * Copy and paste this into your browser console at http://localhost:4000
 * to test WebSocket functionality.
 *
 * Usage:
 * 1. Open browser at http://localhost:4000
 * 2. Open console (F12 or Cmd+Opt+J)
 * 3. Copy this entire file and paste in console
 * 4. Run: testWebSocket(spaceId, userId)
 */

// Main testing function
window.testWebSocket = function(spaceId = 1, userId = 1, x = 50, y = 50) {
  console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 PplWork WebSocket Testing                ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Connecting to space ${spaceId} as user ${userId}...
  `);

  // Create socket connection
  const socket = new Phoenix.Socket("/socket", {
    params: {},
    logger: (kind, msg, data) => {
      console.log(`[${kind}]`, msg, data);
    }
  });

  socket.connect();
  console.log("✅ Socket connected");

  // Create channel
  const channel = socket.channel(`space:${spaceId}`, {
    user_id: userId,
    x: x,
    y: y
  });

  // Set up event listeners
  channel.on("user_joined", payload => {
    console.log(`
👋 USER JOINED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
User ID: ${payload.user_id}
Username: ${payload.avatar.username}
Position: (${payload.avatar.x}, ${payload.avatar.y})
Direction: ${payload.avatar.direction}
    `);
  });

  channel.on("user_moved", payload => {
    console.log(`
🏃 USER MOVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
User ID: ${payload.user_id}
Username: ${payload.avatar.username}
New Position: (${payload.avatar.x}, ${payload.avatar.y})
Direction: ${payload.avatar.direction}
    `);
  });

  channel.on("user_left", payload => {
    console.log(`
👋 USER LEFT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
User ID: ${payload.user_id}
    `);
  });

  channel.on("proximity_update", payload => {
    console.log(`
📍 PROXIMITY UPDATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proximity Groups:`, payload.proximity_groups);

    // Show who's near each avatar
    Object.entries(payload.proximity_groups).forEach(([avatarId, nearbyIds]) => {
      if (nearbyIds.length > 0) {
        console.log(`  Avatar ${avatarId} has ${nearbyIds.length} nearby: [${nearbyIds.join(", ")}]`);
      }
    });
  });

  // Join the channel
  channel.join()
    .receive("ok", resp => {
      console.log(`
✅ SUCCESSFULLY JOINED SPACE ${spaceId}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your Avatar:
  ID: ${resp.current_avatar.id}
  Position: (${resp.current_avatar.x}, ${resp.current_avatar.y})
  Direction: ${resp.current_avatar.direction}

Current Avatars in Space: ${resp.avatars.length}
      `);

      resp.avatars.forEach(avatar => {
        console.log(`  • ${avatar.username} (${avatar.id}) at (${avatar.x}, ${avatar.y})`);
      });

      console.log(`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Available Commands:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Move your avatar
testChannel.move(x, y, direction)

// Get nearby users
testChannel.getNearby(radius)

// Get current space state
testChannel.getState()

// Leave the space
testChannel.leave()

// Quick movements
testChannel.moveUp()
testChannel.moveDown()
testChannel.moveLeft()
testChannel.moveRight()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Example: testChannel.move(25, 30, "up")
      `);
    })
    .receive("error", resp => {
      console.error(`
❌ FAILED TO JOIN SPACE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error:`, resp);
    })
    .receive("timeout", () => {
      console.error("❌ Connection timeout");
    });

  // Create helper object with useful methods
  const testChannel = {
    channel: channel,
    socket: socket,

    move: function(x, y, direction = "down") {
      return channel.push("move", { x, y, direction })
        .receive("ok", resp => {
          console.log(`✅ Moved to (${resp.x}, ${resp.y}) facing ${resp.direction}`);
        })
        .receive("error", resp => {
          console.error("❌ Move failed:", resp);
        });
    },

    moveUp: function(distance = 5) {
      const currentY = this.currentPosition?.y || y;
      return this.move(x, currentY - distance, "up");
    },

    moveDown: function(distance = 5) {
      const currentY = this.currentPosition?.y || y;
      return this.move(x, currentY + distance, "down");
    },

    moveLeft: function(distance = 5) {
      const currentX = this.currentPosition?.x || x;
      return this.move(currentX - distance, y, "left");
    },

    moveRight: function(distance = 5) {
      const currentX = this.currentPosition?.x || x;
      return this.move(currentX + distance, y, "right");
    },

    getNearby: function(radius = 5.0) {
      return channel.push("get_nearby_users", { radius })
        .receive("ok", resp => {
          console.log(`
📍 NEARBY USERS (within radius ${radius})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Found ${resp.nearby_users.length} nearby users:
          `);
          resp.nearby_users.forEach(user => {
            console.log(`  • ${user.username} at (${user.x}, ${user.y})`);
          });
        })
        .receive("error", resp => {
          console.error("❌ Failed to get nearby users:", resp);
        });
    },

    getState: function() {
      return channel.push("get_state", {})
        .receive("ok", resp => {
          console.log(`
📊 SPACE STATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total avatars: ${resp.avatars.length}
          `);
          resp.avatars.forEach(avatar => {
            console.log(`  • ${avatar.username} (${avatar.id}) at (${avatar.x}, ${avatar.y}) ${avatar.is_active ? "🟢" : "🔴"}`);
          });
          console.log("\nProximity groups:", resp.proximity_groups);
        })
        .receive("error", resp => {
          console.error("❌ Failed to get state:", resp);
        });
    },

    leave: function() {
      channel.leave()
        .receive("ok", () => {
          console.log("✅ Left the space");
        });
    },

    // Helper to track current position
    currentPosition: { x, y }
  };

  // Store in window for easy access
  window.testChannel = testChannel;

  return testChannel;
};

// Quick start function with multiple users (for testing interactions)
window.startMultiUserTest = function() {
  console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 Multi-User WebSocket Testing             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Opening multiple connections for testing...
  `);

  // User 1 (Alice)
  const alice = testWebSocket(1, 1, 10, 10);
  setTimeout(() => {
    console.log("\n🔄 Alice is moving...");
    alice.move(15, 15, "right");
  }, 2000);

  console.log(`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To test with more users, open another browser window
in incognito mode and run:

testWebSocket(1, 2, 20, 20)  // Connect as user 2

Then try moving:
testChannel.move(25, 25, "up")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  `);

  return alice;
};

// Proximity testing scenario
window.testProximity = function() {
  console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     📍 Proximity Detection Testing               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

This test demonstrates proximity detection.

Instructions:
1. Open TWO browser windows/tabs
2. In Window 1, run: testProximity()
3. In Window 2, run: testWebSocket(1, 2, 12, 12)
4. In Window 2, try: testChannel.move(50, 50)

You should see proximity_update events when users
are within 5 units of each other!
  `);

  const user1 = testWebSocket(1, 1, 10, 10);

  setTimeout(() => {
    console.log("\n🔍 Checking for nearby users...");
    user1.getNearby(10);
  }, 2000);

  return user1;
};

// Display welcome message
console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🚀 PplWork WebSocket Testing Loaded         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Available Functions:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

testWebSocket(spaceId, userId, x, y)
  → Connect to a space
  → Default: testWebSocket(1, 1, 50, 50)

startMultiUserTest()
  → Start multi-user testing scenario

testProximity()
  → Test proximity detection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Start:
testWebSocket(1, 1)

Then use:
testChannel.move(x, y, direction)
testChannel.getNearby()
testChannel.getState()
testChannel.leave()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);
