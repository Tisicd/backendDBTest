-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO users (name, email) VALUES 
    ('Juan Pérez', 'juan@example.com'),
    ('María García', 'maria@example.com')
ON CONFLICT (email) DO NOTHING;



