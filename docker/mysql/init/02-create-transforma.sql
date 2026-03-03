CREATE DATABASE IF NOT EXISTS transforma;

-- Optional: allow your existing app user to access it
GRANT ALL PRIVILEGES ON transforma.* TO 'starline'@'%';
FLUSH PRIVILEGES;