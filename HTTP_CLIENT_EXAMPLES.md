# HTTP Client Examples - PplWork API

Ejemplos de cómo usar la API de PplWork con diferentes clientes HTTP.

## Tabla de Contenidos

- [cURL](#curl)
- [HTTPie](#httpie)
- [JavaScript (fetch)](#javascript-fetch)
- [Python (requests)](#python-requests)
- [Postman/Insomnia](#postmaninsomnia)

---

## cURL

### Usuarios

**Registrar usuario:**
```bash
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "username": "myusername",
      "password": "Password123"
    }
  }'
```

**Login:**
```bash
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123"
  }'
```

**Ver usuario:**
```bash
curl http://localhost:4000/api/users/1
```

### Espacios

**Listar espacios públicos:**
```bash
curl http://localhost:4000/api/spaces
```

**Ver espacio específico:**
```bash
curl http://localhost:4000/api/spaces/1
```

**Crear espacio:**
```bash
curl -X POST http://localhost:4000/api/spaces \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Mi Espacio",
      "width": 100,
      "height": 100,
      "description": "Un espacio de trabajo",
      "is_public": true,
      "max_occupancy": 50
    }
  }'
```

**Actualizar espacio:**
```bash
curl -X PUT http://localhost:4000/api/spaces/1 \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Espacio Actualizado",
      "max_occupancy": 75
    }
  }'
```

**Eliminar espacio:**
```bash
curl -X DELETE http://localhost:4000/api/spaces/1
```

**Ver ocupación:**
```bash
curl http://localhost:4000/api/spaces/1/occupancy
```

---

## HTTPie

[HTTPie](https://httpie.io/) es una alternativa más amigable a cURL.

**Instalación:**
```bash
# macOS
brew install httpie

# Linux
apt install httpie

# Python
pip install httpie
```

### Usuarios

**Registrar usuario:**
```bash
http POST localhost:4000/api/users/register \
  user:='{
    "email": "user@example.com",
    "username": "myusername",
    "password": "Password123"
  }'
```

**Login:**
```bash
http POST localhost:4000/api/users/login \
  email=user@example.com \
  password=Password123
```

**Ver usuario:**
```bash
http GET localhost:4000/api/users/1
```

### Espacios

**Listar espacios:**
```bash
http GET localhost:4000/api/spaces
```

**Crear espacio:**
```bash
http POST localhost:4000/api/spaces \
  space:='{
    "name": "Mi Espacio",
    "width": 100,
    "height": 100,
    "description": "Un espacio de trabajo",
    "is_public": true,
    "max_occupancy": 50
  }'
```

**Actualizar espacio:**
```bash
http PUT localhost:4000/api/spaces/1 \
  space:='{"name": "Espacio Actualizado"}'
```

**Eliminar espacio:**
```bash
http DELETE localhost:4000/api/spaces/1
```

---

## JavaScript (fetch)

### Usuarios

**Registrar usuario:**
```javascript
fetch('http://localhost:4000/api/users/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    user: {
      email: 'user@example.com',
      username: 'myusername',
      password: 'Password123'
    }
  })
})
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

**Login:**
```javascript
fetch('http://localhost:4000/api/users/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'Password123'
  })
})
  .then(response => response.json())
  .then(data => {
    console.log('User:', data.data);
    // Guardar user ID para uso posterior
    localStorage.setItem('userId', data.data.id);
  });
```

**Ver usuario:**
```javascript
const userId = 1;

fetch(`http://localhost:4000/api/users/${userId}`)
  .then(response => response.json())
  .then(data => console.log(data.data));
```

### Espacios

**Listar espacios:**
```javascript
fetch('http://localhost:4000/api/spaces')
  .then(response => response.json())
  .then(data => {
    console.log('Spaces:', data.data);
    data.data.forEach(space => {
      console.log(`- ${space.name} (${space.width}x${space.height})`);
    });
  });
```

**Crear espacio:**
```javascript
fetch('http://localhost:4000/api/spaces', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    space: {
      name: 'Mi Espacio',
      width: 100,
      height: 100,
      description: 'Un espacio de trabajo',
      is_public: true,
      max_occupancy: 50
    }
  })
})
  .then(response => response.json())
  .then(data => {
    console.log('Created space:', data.data);
    return data.data.id;
  });
```

**Actualizar espacio:**
```javascript
const spaceId = 1;

fetch(`http://localhost:4000/api/spaces/${spaceId}`, {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    space: {
      name: 'Espacio Actualizado',
      max_occupancy: 75
    }
  })
})
  .then(response => response.json())
  .then(data => console.log('Updated:', data.data));
```

**Eliminar espacio:**
```javascript
const spaceId = 1;

fetch(`http://localhost:4000/api/spaces/${spaceId}`, {
  method: 'DELETE'
})
  .then(response => {
    if (response.status === 204) {
      console.log('Space deleted');
    }
  });
```

**Ver ocupación:**
```javascript
const spaceId = 1;

fetch(`http://localhost:4000/api/spaces/${spaceId}/occupancy`)
  .then(response => response.json())
  .then(data => {
    console.log(`Occupancy: ${data.current_occupancy}/${data.max_occupancy}`);
    console.log(`At capacity: ${data.at_capacity}`);
  });
```

### Clase Helper para API

```javascript
class PplWorkAPI {
  constructor(baseURL = 'http://localhost:4000') {
    this.baseURL = baseURL;
    this.userId = null;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (response.status === 204) {
      return null;
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Request failed');
    }

    return data;
  }

  // Users
  async register(email, username, password) {
    const data = await this.request('/api/users/register', {
      method: 'POST',
      body: JSON.stringify({
        user: { email, username, password }
      }),
    });
    this.userId = data.data.id;
    return data.data;
  }

  async login(email, password) {
    const data = await this.request('/api/users/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    this.userId = data.data.id;
    return data.data;
  }

  async getUser(userId) {
    const data = await this.request(`/api/users/${userId}`);
    return data.data;
  }

  // Spaces
  async listSpaces() {
    const data = await this.request('/api/spaces');
    return data.data;
  }

  async getSpace(spaceId) {
    const data = await this.request(`/api/spaces/${spaceId}`);
    return data.data;
  }

  async createSpace(spaceData) {
    const data = await this.request('/api/spaces', {
      method: 'POST',
      body: JSON.stringify({ space: spaceData }),
    });
    return data.data;
  }

  async updateSpace(spaceId, updates) {
    const data = await this.request(`/api/spaces/${spaceId}`, {
      method: 'PUT',
      body: JSON.stringify({ space: updates }),
    });
    return data.data;
  }

  async deleteSpace(spaceId) {
    await this.request(`/api/spaces/${spaceId}`, {
      method: 'DELETE',
    });
  }

  async getSpaceOccupancy(spaceId) {
    return await this.request(`/api/spaces/${spaceId}/occupancy`);
  }
}

// Uso:
const api = new PplWorkAPI();

// Registrar y crear espacio
await api.register('user@example.com', 'username', 'Password123');
const space = await api.createSpace({
  name: 'Mi Espacio',
  width: 100,
  height: 100,
  is_public: true,
  max_occupancy: 50
});
console.log('Created:', space);
```

---

## Python (requests)

**Instalación:**
```bash
pip install requests
```

### Usuarios

**Registrar usuario:**
```python
import requests

response = requests.post(
    'http://localhost:4000/api/users/register',
    json={
        'user': {
            'email': 'user@example.com',
            'username': 'myusername',
            'password': 'Password123'
        }
    }
)

user = response.json()['data']
print(f"User ID: {user['id']}")
```

**Login:**
```python
response = requests.post(
    'http://localhost:4000/api/users/login',
    json={
        'email': 'user@example.com',
        'password': 'Password123'
    }
)

user = response.json()['data']
print(f"Logged in as: {user['username']}")
```

### Espacios

**Listar espacios:**
```python
response = requests.get('http://localhost:4000/api/spaces')
spaces = response.json()['data']

for space in spaces:
    print(f"- {space['name']} ({space['width']}x{space['height']})")
```

**Crear espacio:**
```python
response = requests.post(
    'http://localhost:4000/api/spaces',
    json={
        'space': {
            'name': 'Mi Espacio',
            'width': 100,
            'height': 100,
            'description': 'Un espacio de trabajo',
            'is_public': True,
            'max_occupancy': 50
        }
    }
)

space = response.json()['data']
print(f"Created space ID: {space['id']}")
```

### Clase Helper para Python

```python
import requests

class PplWorkAPI:
    def __init__(self, base_url='http://localhost:4000'):
        self.base_url = base_url
        self.user_id = None

    def _request(self, method, endpoint, **kwargs):
        url = f"{self.base_url}{endpoint}"
        response = requests.request(method, url, **kwargs)

        if response.status_code == 204:
            return None

        data = response.json()

        if not response.ok:
            raise Exception(data.get('error', 'Request failed'))

        return data

    # Users
    def register(self, email, username, password):
        data = self._request('POST', '/api/users/register', json={
            'user': {'email': email, 'username': username, 'password': password}
        })
        self.user_id = data['data']['id']
        return data['data']

    def login(self, email, password):
        data = self._request('POST', '/api/users/login', json={
            'email': email, 'password': password
        })
        self.user_id = data['data']['id']
        return data['data']

    def get_user(self, user_id):
        data = self._request('GET', f'/api/users/{user_id}')
        return data['data']

    # Spaces
    def list_spaces(self):
        data = self._request('GET', '/api/spaces')
        return data['data']

    def get_space(self, space_id):
        data = self._request('GET', f'/api/spaces/{space_id}')
        return data['data']

    def create_space(self, **space_data):
        data = self._request('POST', '/api/spaces', json={'space': space_data})
        return data['data']

    def update_space(self, space_id, **updates):
        data = self._request('PUT', f'/api/spaces/{space_id}', json={'space': updates})
        return data['data']

    def delete_space(self, space_id):
        self._request('DELETE', f'/api/spaces/{space_id}')

    def get_space_occupancy(self, space_id):
        return self._request('GET', f'/api/spaces/{space_id}/occupancy')

# Uso:
api = PplWorkAPI()

# Registrar usuario
user = api.register('user@example.com', 'username', 'Password123')
print(f"Registered user: {user['username']}")

# Crear espacio
space = api.create_space(
    name='Mi Espacio',
    width=100,
    height=100,
    is_public=True,
    max_occupancy=50
)
print(f"Created space: {space['name']}")

# Listar espacios
spaces = api.list_spaces()
for space in spaces:
    print(f"- {space['name']}")
```

---

## Postman/Insomnia

### Importar Collection

Guarda este JSON como `pplwork_collection.json`:

```json
{
  "name": "PplWork API",
  "description": "API Collection for PplWork",
  "variables": {
    "base_url": "http://localhost:4000"
  },
  "requests": [
    {
      "name": "Register User",
      "method": "POST",
      "url": "{{base_url}}/api/users/register",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "user": {
          "email": "user@example.com",
          "username": "myusername",
          "password": "Password123"
        }
      }
    },
    {
      "name": "Login",
      "method": "POST",
      "url": "{{base_url}}/api/users/login",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "email": "user@example.com",
        "password": "Password123"
      }
    },
    {
      "name": "Get User",
      "method": "GET",
      "url": "{{base_url}}/api/users/1"
    },
    {
      "name": "List Spaces",
      "method": "GET",
      "url": "{{base_url}}/api/spaces"
    },
    {
      "name": "Get Space",
      "method": "GET",
      "url": "{{base_url}}/api/spaces/1"
    },
    {
      "name": "Create Space",
      "method": "POST",
      "url": "{{base_url}}/api/spaces",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "space": {
          "name": "Mi Espacio",
          "width": 100,
          "height": 100,
          "description": "Un espacio de trabajo",
          "is_public": true,
          "max_occupancy": 50
        }
      }
    },
    {
      "name": "Update Space",
      "method": "PUT",
      "url": "{{base_url}}/api/spaces/1",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": {
        "space": {
          "name": "Espacio Actualizado",
          "max_occupancy": 75
        }
      }
    },
    {
      "name": "Delete Space",
      "method": "DELETE",
      "url": "{{base_url}}/api/spaces/1"
    },
    {
      "name": "Get Space Occupancy",
      "method": "GET",
      "url": "{{base_url}}/api/spaces/1/occupancy"
    }
  ]
}
```

**Importar en Postman:**
1. Abrir Postman
2. File → Import
3. Seleccionar `pplwork_collection.json`
4. Configurar variable `base_url` si es necesario

**Importar en Insomnia:**
1. Abrir Insomnia
2. Application → Preferences → Data → Import Data
3. Seleccionar `pplwork_collection.json`

---

## Ejemplos Avanzados

### Flujo Completo de Testing

**JavaScript:**
```javascript
async function completeTest() {
  const api = new PplWorkAPI();

  // 1. Registrar usuario
  console.log('1. Registering user...');
  const user = await api.register('test@test.com', 'testuser', 'Password123');
  console.log(`✓ User created: ${user.username} (ID: ${user.id})`);

  // 2. Crear espacio
  console.log('2. Creating space...');
  const space = await api.createSpace({
    name: 'Test Space',
    width: 50,
    height: 50,
    is_public: true,
    max_occupancy: 10
  });
  console.log(`✓ Space created: ${space.name} (ID: ${space.id})`);

  // 3. Listar espacios
  console.log('3. Listing spaces...');
  const spaces = await api.listSpaces();
  console.log(`✓ Found ${spaces.length} spaces`);

  // 4. Verificar ocupancy
  console.log('4. Checking occupancy...');
  const occupancy = await api.getSpaceOccupancy(space.id);
  console.log(`✓ Occupancy: ${occupancy.current_occupancy}/${occupancy.max_occupancy}`);

  // 5. Actualizar espacio
  console.log('5. Updating space...');
  const updated = await api.updateSpace(space.id, {
    name: 'Updated Test Space'
  });
  console.log(`✓ Space updated: ${updated.name}`);

  // 6. Eliminar espacio
  console.log('6. Deleting space...');
  await api.deleteSpace(space.id);
  console.log('✓ Space deleted');

  console.log('\n✅ All tests passed!');
}

completeTest().catch(console.error);
```

---

## Notas

- Todos los ejemplos asumen que el servidor está corriendo en `http://localhost:4000`
- Los endpoints requieren `Content-Type: application/json` para requests con body
- Las respuestas exitosas devuelven status 200 con `{data: {...}}`
- Los errores devuelven status 4xx/5xx con `{error: "..."}` o `{errors: {...}}`
- Ver [TESTING_GUIDE.md](TESTING_GUIDE.md) para más ejemplos y casos de uso

