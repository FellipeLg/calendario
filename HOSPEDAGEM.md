# Hospedagem do Projeto Calendário

Guia completo para hospedar o site na internet.

---

## Opção 1: Render.com (Grátis, Mais Fácil)

### O que é
Plataforma PaaS gratuita que hospeda seu Rails automaticamente. Os dados ficam no PostgreSQL gratuito (500MB).

### Passo a passo

1. Acesse https://render.com e crie uma conta (pode usar login do GitHub)
2. Clique em **"New +"** → **"Web Service"**
3. Conecte seu repositório GitHub: `FellipeLg/calendario`
4. Configure os campos:
   - **Name**: `calendario`
   - **Runtime**: Ruby
   - **Build Command**: `./bin/setup`
   - **Start Command**: `bin/rails server`
   - **Plan**: Free
5. No painel lateral, vá em **Environment** → adicione:
   - `RAILS_ENV` = `production`
6. Clique em **"Create Web Service"**
7. Aguarde 2-3 minutos para o build completar

### Criando o banco de dados

1. No painel do Render, clique em **"New +"** → **"PostgreSQL"**
2. Configure:
   - **Name**: `calendario-db`
   - **Plan**: Free
   - **Database Name**: `calendario`
3. Clique em **"Create Database"**
4. Volte para o Web Service → **Environment** → adicione:
   - `DATABASE_URL` = clique em **"Add from Database"** → selecione `calendario-db`
5. Clique em **"Manual Deploy"** → **"Deploy latest commit"**

### Resultado
- Site: `https://calendario.onrender.com`
- Dados: Persistentes no PostgreSQL
- Limite: App dorme após 15 min sem uso (leva ~30s para acordar)

---

## Opção 2: Hostinger VPS (Pago, Completo)

### O que é
Um servidor virtual privado (VPS) onde você tem controle total. O site roda 24/7 sem dormir.

### Requisitos
- VPS Hostinger (plano KVM 2 ou superior, ~R$/mês)
- Terminal no computador (Mac/Linux) ou PuTTY (Windows)

### Passo 1: Comprar o VPS

1. Acesse https://hostinger.com.br
2. Vá em **VPS** → escolha **KVM 2** (mínimo 2GB RAM)
3. Selecione **Ubuntu 22.04** como sistema operacional
4. Finalize a compra
5. Anote o **IP do servidor** e a **senha root** (chega por email)

### Passo 2: Conectar no servidor

Abra o terminal e rode:

```bash
ssh root@SEU_IP_DO_SERVIDOR
```

Na primeira conexão, digite `yes` e depois a senha.

### Passo 3: Baixar o projeto

```bash
# Atualizar o sistema
apt-get update && apt-get upgrade -y

# Instalar git
apt-get install -y git

# Baixar o projeto
git clone https://github.com/FellipeLg/calendario.git
cd calendario

# Rodar o script de configuração
bash bin/deploy-setup.sh
```

O script vai instalar:
- Docker e Docker Compose
- Nginx (servidor web)
- Certbot (SSL gratuito)
- Firewall

### Passo 4: Configurar variáveis de ambiente

Gere os valores de segurança:

```bash
# Gere 3 valores diferentes (copie cada um)
openssl rand -hex 32  # 1º valor = RAILS_MASTER_KEY
openssl rand -hex 32  # 2º valor = SECRET_KEY_BASE
openssl rand -hex 32  # 3º valor = DB_PASSWORD
```

Crie o arquivo de configuração:

```bash
cat > .env.production << 'EOF'
RAILS_MASTER_KEY=COLE_O_PRIMEIRO_VALOR_AQUI
SECRET_KEY_BASE=COLE_O_SEGUNDO_VALOR_AQUI
DB_PASSWORD=COLE_O_TERCEIRO_VALOR_AQUI
APP_DOMAIN=SEU_IP_DO_SERVIDOR
EOF
```

> **Importante**: Substitua os textos "COLE_O_VALOR_AQUI" pelos valores reais gerados.

### Passo 5: Subir o projeto

```bash
# Build e subir containers
docker compose up -d --build

# Rodar migrações do banco
docker compose exec web bin/rails db:migrate

# Verificar se está rodando
docker compose ps
```

### Passo 6: Acessar o site

- **Sem domínio**: `http://SEU_IP:3000`
- **Com domínio**: Configure o DNS do domínio para apontar para o IP, depois rode:

```bash
# Configurar Nginx para domínio
cat > /etc/nginx/sites-available/calendario << 'NGINX'
server {
    listen 80;
    server_name SEUDOMINIO.com.br;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

ln -s /etc/nginx/sites-available/calendario /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Gerar SSL gratuito
certbot --nginx -d SEUDOMINIO.com.br
```

### Comandos úteis no VPS

| Comando | O que faz |
|---------|-----------|
| `docker compose logs -f` | Ver logs em tempo real |
| `docker compose restart web` | Reiniciar o app |
| `docker compose exec web bin/rails console` | Console Rails |
| `docker compose down` | Parar tudo |
| `docker compose up -d` | Subir tudo |
| `docker compose up -d --build` | Reconstruir e subir |

---

## Comparação

| | Render.com | Hostinger VPS |
|---|---|---|
| **Preço** | Grátis | ~R$/mês |
| **Setup** | 5 min | 30 min |
| **Dados** | Persistem | Persistem |
| **Performance** | Básica | Boa |
| **Dorme sim?** | Sim (15 min) | Não |
| **Controle total** | Não | Sim |
| **Domínio próprio** | Sim | Sim |
| **SSL grátis** | Automático | Certbot |

---

## Solução de Problemas

### Build falhou no Render
Verifique se o `DATABASE_URL` está configurado. Clique em **"Manual Deploy"** → **"Deploy latest commit"**.

### Site não abre no VPS
```bash
docker compose logs web  # Ver erro
docker compose restart web  # Reiniciar
```

### Erro de banco de dados
```bash
docker compose exec web bin/rails db:migrate
```

### Esqueci a senha do VPS
No painel da Hostinger → VPS → **Reinstalar sistema** (apaga tudo, mas resolve).

### Quer atualizar o código
```bash
cd calendario
git pull
docker compose up -d --build
docker compose exec web bin/rails db:migrate
```
