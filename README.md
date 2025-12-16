# BackDB - Aplicación Backend con Base de Datos

Aplicación sencilla con backend separado y base de datos PostgreSQL, con CI/CD automatizado mediante GitHub Actions para despliegue en múltiples instancias EC2 de AWS.

## 🏗️ Estructura del Proyecto

```
backdb/
├── backend/              # Aplicación Node.js/Express
│   ├── server.js        # Servidor principal
│   ├── package.json     # Dependencias Node.js
│   └── .env.example     # Variables de entorno de ejemplo
├── database/            # Configuración de base de datos
│   ├── Dockerfile       # Imagen Docker para PostgreSQL
│   └── init.sql         # Script de inicialización
├── scripts/             # Scripts de despliegue
│   ├── deploy.sh        # Script de despliegue manual
│   └── setup-ec2.sh     # Script de configuración inicial EC2
├── .github/
│   └── workflows/
│       └── deploy.yml   # Workflow de GitHub Actions
└── docker-compose.yml   # Orquestación de servicios
```

## 🚀 Inicio Rápido (Desarrollo Local)

### Prerrequisitos

- Docker y Docker Compose instalados
- Node.js 18+ (opcional, para desarrollo)

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone <tu-repositorio>
   cd backdb
   ```

2. **Iniciar la base de datos**
   ```bash
   docker-compose up -d db
   ```

3. **Configurar variables de entorno**
   ```bash
   # El archivo .env ya está creado con la configuración correcta
   # Si necesitas recrearlo, copia desde .env.example:
   cp backend/.env.example backend/.env
   ```
   
   **Importante**: El archivo `.env` debe tener `DB_PORT=5433` porque PostgreSQL en Docker está mapeado al puerto 5433 para evitar conflictos con PostgreSQL local.

4. **Instalar dependencias del backend**
   ```bash
   cd backend
   npm install
   ```

5. **Iniciar el servidor**
   ```bash
   npm start
   # O para desarrollo con auto-reload:
   npm run dev
   ```

6. **Verificar que funciona**
   ```bash
   curl http://localhost:3000/health
   ```

## 📡 Endpoints de la API

- `GET /health` - Verificar estado del servidor y conexión a BD
- `GET /api/users` - Obtener todos los usuarios
- `GET /api/users/:id` - Obtener un usuario por ID
- `POST /api/users` - Crear un nuevo usuario

Ejemplo:
```bash
# Crear usuario
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com"}'

# Obtener usuarios
curl http://localhost:3000/api/users
```

## ☁️ Despliegue en AWS EC2

### Configuración Inicial de EC2

1. **Configurar la instancia EC2**
   ```bash
   # Conectarse a la instancia EC2
   ssh -i tu-clave.pem ubuntu@tu-instancia-ec2
   
   # Ejecutar script de configuración
   # (Copiar el contenido de scripts/setup-ec2.sh y ejecutarlo)
   ```

2. **Configurar Secrets en GitHub**

   Ve a tu repositorio → Settings → Secrets and variables → Actions y agrega:

   - `EC2_HOST_1`: Dirección IP o hostname de tu instancia EC2
   - `EC2_USER_1`: Usuario SSH (normalmente `ubuntu` o `ec2-user`)
   - `EC2_SSH_KEY_1`: Contenido completo de tu clave SSH privada (.pem)

   Para múltiples instancias, agrega:
   - `EC2_HOST_2`, `EC2_USER_2`, `EC2_SSH_KEY_2`, etc.

3. **Configurar archivo .env en EC2**

   Conectarse a EC2 y crear `~/.env.backdb`:
   ```bash
   ssh -i tu-clave.pem ubuntu@tu-instancia-ec2
   nano ~/.env.backdb
   ```
   
   Contenido:
   ```
   PORT=3000
   DB_HOST=db
   DB_PORT=5432
   DB_NAME=backdb
   DB_USER=postgres
   DB_PASSWORD=tu-password-seguro
   ```

### Despliegue Automático

El despliegue se ejecuta automáticamente cuando:
- Se hace push a la rama `main` o `develop`
- Se crea un pull request a `main` (solo build, sin deploy)

### Despliegue Manual

Si necesitas desplegar manualmente:

```bash
# Dar permisos de ejecución
chmod +x scripts/deploy.sh

# Ejecutar despliegue
./scripts/deploy.sh <EC2_HOST> <EC2_USER> <RUTA_CLAVE_SSH>

# O con variables de entorno
export EC2_HOST=tu-instancia.ec2.amazonaws.com
export EC2_USER=ubuntu
export SSH_KEY_PATH=~/.ssh/tu-clave.pem
./scripts/deploy.sh
```

## 🔧 Configuración de GitHub Actions

El workflow `.github/workflows/deploy.yml` está configurado para:

1. **Build**: Empaquetar el código en archivos tar.gz
2. **Deploy**: Desplegar a múltiples instancias EC2 en paralelo

Para agregar más instancias EC2, edita el archivo `deploy.yml` y agrega entradas en la matriz `ec2-instance`.

## 🐳 Docker

### Servicios

- **db**: PostgreSQL 15
- **backend**: (opcional) Puede ejecutarse en Docker también

### Comandos útiles

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Reconstruir imágenes
docker-compose up -d --build
```

## 📝 Variables de Entorno

Copia `backend/.env.example` a `backend/.env` y configura:

- `PORT`: Puerto del servidor (default: 3000)
- `DB_HOST`: Host de la base de datos
- `DB_PORT`: Puerto de la base de datos (default: 5432)
- `DB_NAME`: Nombre de la base de datos
- `DB_USER`: Usuario de la base de datos
- `DB_PASSWORD`: Contraseña de la base de datos

## 🔧 Solución de Problemas

### Puerto 3000 en uso

Si obtienes el error `EADDRINUSE: address already in use :::3000`:

```powershell
# Ver qué proceso está usando el puerto
netstat -ano | findstr :3000

# Detener procesos Node.js
Get-Process | Where-Object {$_.ProcessName -eq "node"} | Stop-Process -Force

# O detener Docker Compose si está corriendo
docker-compose down
```

### Puerto 5432 en uso (PostgreSQL local)

Si tienes PostgreSQL instalado localmente en Windows, el contenedor Docker usa el puerto **5433** para evitar conflictos. Asegúrate de que tu `backend/.env` tenga:

```env
DB_PORT=5433
```

### Error de autenticación de PostgreSQL

Si obtienes `la autentificación password falló para el usuario 'postgres'`:

1. **Verifica que el contenedor esté corriendo:**
   ```powershell
   docker ps
   ```

2. **Verifica el archivo `.env`:**
   ```powershell
   Get-Content backend\.env
   ```
   
   Debe tener exactamente:
   ```env
   PORT=3000
   DB_HOST=localhost
   DB_PORT=5433
   DB_NAME=backdb
   DB_USER=postgres
   DB_PASSWORD=postgres
   ```

3. **Prueba la conexión directa al contenedor:**
   ```powershell
   docker exec -it backdb-postgres psql -U postgres -d backdb -c "SELECT 1;"
   ```

4. **Usa el script de verificación:**
   ```powershell
   .\scripts\check-ports.ps1
   ```

### Verificar configuración

El backend ahora muestra logs de configuración al iniciar. Verifica que los valores sean correctos:

```
=== Configuración de Base de Datos ===
DB_HOST: localhost
DB_PORT: 5433
DB_NAME: backdb
DB_USER: postgres
DB_PASSWORD: ***configurado***
=====================================
```

## 🔒 Seguridad

- ⚠️ **Nunca** subas archivos `.env` al repositorio
- ⚠️ Usa contraseñas seguras en producción
- ⚠️ Configura grupos de seguridad en EC2 para permitir solo puertos necesarios
- ⚠️ Considera usar AWS Secrets Manager para credenciales en producción

## 📚 Tecnologías Utilizadas

- **Backend**: Node.js, Express
- **Base de Datos**: PostgreSQL
- **Containerización**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Cloud**: AWS EC2

## 🤝 Contribuir

1. Crear una rama desde `develop`
2. Realizar cambios
3. Crear pull request a `develop` o `main`

## 📄 Licencia

ISC



