# ✅ WebSocket Testing Fix

## Problema Resuelto

**Error original:**
```
Uncaught ReferenceError: Phoenix is not defined
```

Al intentar ejecutar `testWebSocket(1, 1)` en la consola del navegador.

## Causa

El script `websocket_test.js` intentaba usar `new Phoenix.Socket()`, pero aunque Phoenix estaba importado en `app.js`, no estaba expuesto en el objeto global `window`.

## Solución Implementada

### Archivo Modificado: `assets/js/app.js`

Se agregó al final del bloque de desarrollo:

```javascript
if (process.env.NODE_ENV === "development") {
  // ... código existente ...

  // Expose Phoenix globally for WebSocket testing
  window.Phoenix = { Socket }
}
```

Esto expone `Phoenix.Socket` globalmente solo en modo desarrollo, permitiendo que el script de testing funcione correctamente.

## Documentación Actualizada

### 1. HOW_TO_TEST.md
- ✅ Nota agregada sobre recargar la página después de modificar `app.js`
- ✅ Nueva sección de troubleshooting para "Phoenix is not defined"

### 2. TESTING_GUIDE.md
- ✅ Sección de troubleshooting ampliada con instrucciones detalladas
- ✅ Explicación de que Phoenix solo está disponible en desarrollo

## Cómo Usar Ahora

### Paso 1: Reiniciar el Servidor

Si el servidor estaba corriendo, reinícialo para compilar los cambios en JavaScript:

```bash
# Detener el servidor (Ctrl+C)
# Reiniciar
make server
```

### Paso 2: Recargar la Página

En tu navegador:
1. Ir a http://localhost:4000
2. **Recargar la página** (Cmd+R o F5)
3. Abrir consola (F12)

### Paso 3: Verificar que Phoenix Está Disponible

En la consola del navegador:

```javascript
console.log(window.Phoenix)
// Debe mostrar: {Socket: ƒ}
```

### Paso 4: Cargar el Script de Testing

Copiar y pegar el contenido de `assets/js/websocket_test.js` en la consola.

### Paso 5: Ejecutar Tests

```javascript
testWebSocket(1, 1)
```

Ahora debería funcionar sin errores! ✅

## Verificación Rápida

```javascript
// 1. Verificar que Phoenix existe
window.Phoenix  // {Socket: ƒ}

// 2. Cargar script de testing
// (copiar contenido de websocket_test.js)

// 3. Probar conexión
testWebSocket(1, 1)

// 4. Deberías ver:
// ╔═══════════════════════════════════════════════════╗
// ║     🧪 PplWork WebSocket Testing                ║
// ╚═══════════════════════════════════════════════════╝
// ✅ Socket connected
// ...
```

## Notas Importantes

- ✅ **Solo en desarrollo:** `window.Phoenix` solo está disponible en `NODE_ENV=development`
- ✅ **Requiere recarga:** Después de modificar `app.js`, siempre recarga la página
- ✅ **No afecta producción:** El código de testing no se incluye en builds de producción
- ✅ **Seguro:** Solo expone `Socket`, no toda la librería Phoenix

## Alternativa (Si No Quieres Modificar app.js)

Si prefieres no exponer Phoenix globalmente, puedes modificar el script antes de pegarlo:

```javascript
// Al inicio del script, agregar:
const Socket = window.liveSocket.socket.constructor;

// Luego reemplazar todas las instancias de:
new Phoenix.Socket(...)
// Por:
new Socket(...)
```

Pero la solución implementada es más limpia y conveniente.

## Troubleshooting

### Aún obtengo "Phoenix is not defined"

1. **Verifica que el servidor se reinició:**
   ```bash
   # Detener y reiniciar
   make server
   ```

2. **Verifica que recargaste la página:**
   - Cmd+R (Mac) o F5 (Windows/Linux)
   - O hard reload: Cmd+Shift+R (Mac) o Ctrl+Shift+R (Windows/Linux)

3. **Verifica en consola:**
   ```javascript
   console.log(window.Phoenix)
   ```
   - Si muestra `undefined`, algo salió mal
   - Si muestra `{Socket: ƒ}`, está correcto

4. **Verifica app.js:**
   ```bash
   # Buscar la línea agregada
   grep -n "window.Phoenix" assets/js/app.js
   ```
   Debería mostrar la línea donde se expone Phoenix

### El servidor no reinicia

```bash
# Forzar detención
pkill -f "mix phx.server"

# O simplemente Ctrl+C en la terminal del servidor

# Reiniciar
make server
```

## Resumen

✅ **Problema:** Phoenix no estaba disponible globalmente
✅ **Solución:** Exponer `window.Phoenix = { Socket }` en desarrollo
✅ **Resultado:** WebSocket testing funciona perfectamente
✅ **Documentación:** Actualizada con troubleshooting

¡Listo para probar WebSockets! 🚀
