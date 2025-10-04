/**
 * User Socket - WebSocket connection for PplWork spaces
 */

import { Socket } from "phoenix"

// Socket instance (singleton)
let socket = null

/**
 * Initialize WebSocket connection
 * @returns {Socket} Phoenix Socket instance
 */
export function initSocket() {
  if (socket) {
    return socket
  }

  socket = new Socket("/socket", {
    params: {},
    logger: (kind, msg, data) => {
      if (process.env.NODE_ENV === "development") {
        console.log(`[Socket ${kind}]`, msg, data)
      }
    }
  })

  socket.connect()
  console.log("🔌 Socket connected")

  return socket
}

/**
 * Get current socket instance
 * @returns {Socket|null}
 */
export function getSocket() {
  return socket
}

/**
 * Join a space channel
 * @param {number} spaceId - Space ID
 * @param {number} userId - User ID
 * @param {number} x - Initial X position
 * @param {number} y - Initial Y position
 * @returns {Channel} Phoenix Channel instance
 */
export function joinSpace(spaceId, userId, x, y) {
  if (!socket) {
    initSocket()
  }

  const channel = socket.channel(`space:${spaceId}`, {
    user_id: userId,
    x: x,
    y: y
  })

  return channel
}
