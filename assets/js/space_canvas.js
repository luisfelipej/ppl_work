/**
 * SpaceCanvas - Renders a 2D virtual space with avatars on a grid
 *
 * Grid: 32x32 pixels per unit
 * Avatars: Circles with usernames
 */

import { joinSpace } from "./user_socket"

const GRID_SIZE = 32 // pixels per unit
const AVATAR_RADIUS = 12 // pixels
const DIRECTION_INDICATOR_SIZE = 6 // pixels

/**
 * Main SpaceCanvas class
 */
export class SpaceCanvas {
  constructor(canvasElement) {
    this.canvas = canvasElement
    this.ctx = canvasElement.getContext("2d")

    // Get data from DOM attributes
    this.spaceId = parseInt(canvasElement.dataset.spaceId)
    this.userId = parseInt(canvasElement.dataset.userId)
    this.username = canvasElement.dataset.username
    this.spaceWidth = parseInt(canvasElement.dataset.spaceWidth)
    this.spaceHeight = parseInt(canvasElement.dataset.spaceHeight)
    this.initialX = parseFloat(canvasElement.dataset.initialX)
    this.initialY = parseFloat(canvasElement.dataset.initialY)

    // Set canvas pixel dimensions
    this.canvas.width = this.spaceWidth * GRID_SIZE
    this.canvas.height = this.spaceHeight * GRID_SIZE

    // State
    this.avatars = new Map() // avatar_id -> avatar data
    this.currentAvatarId = null
    this.channel = null

    // Bind methods
    this.handleCanvasClick = this.handleCanvasClick.bind(this)

    // Initialize
    this.setupEventListeners()
    this.connectToSpace()
  }

  /**
   * Setup DOM event listeners
   */
  setupEventListeners() {
    this.canvas.addEventListener("click", this.handleCanvasClick)
  }

  /**
   * Connect to WebSocket space channel
   */
  connectToSpace() {
    this.updateConnectionStatus("connecting")

    this.channel = joinSpace(
      this.spaceId,
      this.userId,
      this.initialX,
      this.initialY
    )

    // Join channel
    this.channel
      .join()
      .receive("ok", (resp) => {
        console.log("✅ Joined space successfully", resp)
        this.updateConnectionStatus("connected")
        this.handleJoinSuccess(resp)
      })
      .receive("error", (resp) => {
        console.error("❌ Failed to join space", resp)
        this.updateConnectionStatus("error")
      })
      .receive("timeout", () => {
        console.error("❌ Connection timeout")
        this.updateConnectionStatus("timeout")
      })

    // Setup channel event listeners
    this.setupChannelListeners()
  }

  /**
   * Setup WebSocket channel event listeners
   */
  setupChannelListeners() {
    this.channel.on("user_joined", (payload) => {
      console.log("👋 User joined", payload)
      this.addOrUpdateAvatar(payload.avatar)
      this.render()
      this.updateUserList()
    })

    this.channel.on("user_moved", (payload) => {
      console.log("🏃 User moved", payload)
      this.addOrUpdateAvatar(payload.avatar)
      this.render()

      // Update debug info if it's current user
      if (payload.user_id === this.userId) {
        this.updateDebugInfo(payload.avatar)
      }
    })

    this.channel.on("user_left", (payload) => {
      console.log("👋 User left", payload)
      this.removeAvatar(payload.user_id)
      this.render()
      this.updateUserList()
    })

    this.channel.on("proximity_update", (payload) => {
      console.log("📍 Proximity update", payload)
      // Could be used to highlight nearby avatars
    })
  }

  /**
   * Handle successful join
   */
  handleJoinSuccess(resp) {
    // Store current avatar ID
    this.currentAvatarId = resp.current_avatar.id

    // Add all avatars from initial state
    resp.avatars.forEach((avatar) => {
      this.addOrUpdateAvatar(avatar)
    })

    // Initial render
    this.render()
    this.updateUserList()
    this.updateDebugInfo(resp.current_avatar)
  }

  /**
   * Add or update avatar in state
   */
  addOrUpdateAvatar(avatar) {
    this.avatars.set(avatar.id, avatar)
  }

  /**
   * Remove avatar from state
   */
  removeAvatar(userId) {
    // Find avatar by user_id
    for (const [avatarId, avatar] of this.avatars.entries()) {
      if (avatar.user_id === userId) {
        this.avatars.delete(avatarId)
        break
      }
    }
  }

  /**
   * Main render function
   */
  render() {
    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)

    // Render grid
    this.renderGrid()

    // Render all avatars
    this.avatars.forEach((avatar) => {
      this.renderAvatar(avatar)
    })
  }

  /**
   * Render grid lines
   */
  renderGrid() {
    this.ctx.strokeStyle = "#e0e0e0"
    this.ctx.lineWidth = 0.5

    // Vertical lines
    for (let x = 0; x <= this.spaceWidth; x++) {
      const px = x * GRID_SIZE
      this.ctx.beginPath()
      this.ctx.moveTo(px, 0)
      this.ctx.lineTo(px, this.canvas.height)
      this.ctx.stroke()
    }

    // Horizontal lines
    for (let y = 0; y <= this.spaceHeight; y++) {
      const py = y * GRID_SIZE
      this.ctx.beginPath()
      this.ctx.moveTo(0, py)
      this.ctx.lineTo(this.canvas.width, py)
      this.ctx.stroke()
    }
  }

  /**
   * Render a single avatar
   */
  renderAvatar(avatar) {
    // Convert coordinates to pixels (center of grid cell)
    const px = avatar.x * GRID_SIZE + GRID_SIZE / 2
    const py = avatar.y * GRID_SIZE + GRID_SIZE / 2

    // Determine color
    const isCurrentUser = avatar.id === this.currentAvatarId
    const color = isCurrentUser ? "#22c55e" : this.getUserColor(avatar.user_id)

    // Draw circle
    this.ctx.fillStyle = color
    this.ctx.beginPath()
    this.ctx.arc(px, py, AVATAR_RADIUS, 0, Math.PI * 2)
    this.ctx.fill()

    // Draw border for current user
    if (isCurrentUser) {
      this.ctx.strokeStyle = "#16a34a"
      this.ctx.lineWidth = 2
      this.ctx.stroke()
    }

    // Draw direction indicator
    this.renderDirectionIndicator(px, py, avatar.direction, color)

    // Draw username
    this.ctx.fillStyle = "#000"
    this.ctx.font = "12px sans-serif"
    this.ctx.textAlign = "center"
    this.ctx.textBaseline = "top"
    this.ctx.fillText(avatar.username, px, py + AVATAR_RADIUS + 4)
  }

  /**
   * Render direction indicator (small triangle)
   */
  renderDirectionIndicator(px, py, direction, color) {
    const size = DIRECTION_INDICATOR_SIZE

    this.ctx.fillStyle = color
    this.ctx.strokeStyle = "#000"
    this.ctx.lineWidth = 1

    this.ctx.beginPath()

    switch (direction) {
      case "up":
        this.ctx.moveTo(px, py - AVATAR_RADIUS - 2)
        this.ctx.lineTo(px - size, py - AVATAR_RADIUS - 2 - size)
        this.ctx.lineTo(px + size, py - AVATAR_RADIUS - 2 - size)
        break
      case "down":
        this.ctx.moveTo(px, py + AVATAR_RADIUS + 2)
        this.ctx.lineTo(px - size, py + AVATAR_RADIUS + 2 + size)
        this.ctx.lineTo(px + size, py + AVATAR_RADIUS + 2 + size)
        break
      case "left":
        this.ctx.moveTo(px - AVATAR_RADIUS - 2, py)
        this.ctx.lineTo(px - AVATAR_RADIUS - 2 - size, py - size)
        this.ctx.lineTo(px - AVATAR_RADIUS - 2 - size, py + size)
        break
      case "right":
        this.ctx.moveTo(px + AVATAR_RADIUS + 2, py)
        this.ctx.lineTo(px + AVATAR_RADIUS + 2 + size, py - size)
        this.ctx.lineTo(px + AVATAR_RADIUS + 2 + size, py + size)
        break
    }

    this.ctx.closePath()
    this.ctx.fill()
    this.ctx.stroke()
  }

  /**
   * Get consistent color for user based on user_id
   */
  getUserColor(userId) {
    // Simple hash to HSL color
    const hue = (userId * 137.508) % 360 // Golden angle
    return `hsl(${hue}, 70%, 60%)`
  }

  /**
   * Handle canvas click
   */
  handleCanvasClick(event) {
    const rect = this.canvas.getBoundingClientRect()
    const clickX = event.clientX - rect.left
    const clickY = event.clientY - rect.top

    // Convert to grid units
    const unitX = clickX / GRID_SIZE
    const unitY = clickY / GRID_SIZE

    // Get current avatar
    const currentAvatar = this.avatars.get(this.currentAvatarId)
    if (!currentAvatar) return

    // Calculate direction based on movement
    const direction = this.calculateDirection(
      currentAvatar.x,
      currentAvatar.y,
      unitX,
      unitY
    )

    // Send move command
    this.moveAvatar(unitX, unitY, direction)
  }

  /**
   * Calculate direction based on delta movement
   */
  calculateDirection(oldX, oldY, newX, newY) {
    const dx = newX - oldX
    const dy = newY - oldY

    if (Math.abs(dx) > Math.abs(dy)) {
      return dx > 0 ? "right" : "left"
    } else {
      return dy > 0 ? "down" : "up"
    }
  }

  /**
   * Send move command via WebSocket
   */
  moveAvatar(x, y, direction) {
    this.channel
      .push("move", { x, y, direction })
      .receive("ok", (resp) => {
        console.log("✅ Move successful", resp)
      })
      .receive("error", (resp) => {
        console.error("❌ Move failed", resp)
      })
  }

  /**
   * Update connection status badge
   */
  updateConnectionStatus(status) {
    const badge = document.getElementById("connection-status")
    if (!badge) return

    switch (status) {
      case "connecting":
        badge.className = "badge badge-warning"
        badge.textContent = "Connecting..."
        break
      case "connected":
        badge.className = "badge badge-success"
        badge.textContent = "Connected"
        break
      case "error":
        badge.className = "badge badge-error"
        badge.textContent = "Error"
        break
      case "timeout":
        badge.className = "badge badge-error"
        badge.textContent = "Timeout"
        break
    }
  }

  /**
   * Update user list in sidebar
   */
  updateUserList() {
    const userList = document.getElementById("user-list")
    if (!userList) return

    // Clear current list
    userList.innerHTML = ""

    // Add each avatar
    this.avatars.forEach((avatar) => {
      const div = document.createElement("div")
      div.className = `flex items-center gap-2 p-2 rounded ${
        avatar.id === this.currentAvatarId ? "bg-success/20" : "bg-base-300"
      }`

      const color = avatar.id === this.currentAvatarId ? "#22c55e" : this.getUserColor(avatar.user_id)

      div.innerHTML = `
        <div class="w-3 h-3 rounded-full" style="background-color: ${color}"></div>
        <span class="text-sm ${avatar.id === this.currentAvatarId ? "font-semibold" : ""}">${avatar.username}</span>
        ${avatar.id === this.currentAvatarId ? '<span class="text-xs text-success">(you)</span>' : ""}
      `

      userList.appendChild(div)
    })

    // Update debug user count
    const debugUserCount = document.getElementById("debug-user-count")
    if (debugUserCount) {
      debugUserCount.textContent = this.avatars.size
    }
  }

  /**
   * Update debug info
   */
  updateDebugInfo(avatar) {
    const debugPosition = document.getElementById("debug-position")
    if (debugPosition) {
      debugPosition.textContent = `(${avatar.x.toFixed(2)}, ${avatar.y.toFixed(2)})`
    }

    const debugDirection = document.getElementById("debug-direction")
    if (debugDirection) {
      debugDirection.textContent = avatar.direction
    }
  }
}

/**
 * Initialize canvas when DOM is ready
 */
export function initSpaceCanvas() {
  const canvasElement = document.getElementById("space-canvas")
  if (!canvasElement) return

  console.log("🎨 Initializing SpaceCanvas")
  new SpaceCanvas(canvasElement)
}
