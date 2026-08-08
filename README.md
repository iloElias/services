# Infraestrutura Docker

Este Compose reúne serviços de infraestrutura para hospedagem no Dokploy.

## Ordem dos serviços

1. `postgres`
2. `redis`
3. `rabbitmq`
4. `pgbouncer`
5. `minio`
6. `rustfs`

A ordem organiza o template por dependência funcional. O PgBouncer aguarda o PostgreSQL ficar saudável por meio de `depends_on`.

## Rede e portas

Todos os serviços usam a rede Docker externa `global-network`. Antes de iniciar o Compose, execute:

```sh
./init.sh
```

Portas publicadas no host:

- `5432`: PostgreSQL e PgBouncer
- `6379`: Redis
- `15672`: painel de gerenciamento do RabbitMQ

As portas do MinIO (`9100` e `9101`) e AMQP (`5672`) permanecem disponíveis apenas na rede Docker.

## Variáveis

O arquivo `.env` representa o Project Environment `production` usado pelo ambiente de testes. Os valores atuais são de teste e não são credenciais reais.

O arquivo `.env.example` é um template de variáveis de serviço para o Dokploy. Cada variável aponta para a variável correspondente do Project Environment `production` usando o formato `${{ production.VARIABLE }}`.

Os dois arquivos estão agrupados por serviço:

- PostgreSQL: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- PgBouncer: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `ADMIN_USERS`, `POOL_MODE`, `MAX_CLIENT_CONN`, `DEFAULT_POOL_SIZE`, `MIN_POOL_SIZE`, `RESERVE_POOL_SIZE`, `AUTH_TYPE`, `AUTH_FILE`
- PgBouncer aliases: `PGBOUNCER_DB_HOST`, `PGBOUNCER_DB_PORT`, `PGBOUNCER_DB_NAME`, `PGBOUNCER_DB_USER`, `PGBOUNCER_DB_PASSWORD`
- MySQL: `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`
- RabbitMQ: `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS`, `RABBITMQ_DISK_FREE_LIMIT`, `RABBITMQ_VM_MEMORY_HIGH_WATERMARK`, `RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS`
- Jenkins: `JENKINS_PASSWORD`
- MinIO: `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`
- RustFS: `RUSTFS_ACCESS_KEY`, `RUSTFS_SECRET_KEY`, `RUSTFS_VOLUMES`, `RUSTFS_ADDRESS`, `RUSTFS_CONSOLE_ADDRESS`, `RUSTFS_CONSOLE_ENABLE`, `RUSTFS_CORS_ALLOWED_ORIGINS`, `RUSTFS_CONSOLE_CORS_ALLOWED_ORIGINS`, `RUSTFS_OBS_LOGGER_LEVEL`, `RUSTFS_UNSAFE_BYPASS_DISK_CHECK`
- Redis: nenhuma variável externa atualmente

MySQL e Jenkins não possuem serviços neste Compose atualmente. Suas variáveis foram preservadas e documentadas para evitar resolver conflitos ou contratos futuros neste passo.

Todos os serviços declaram `env_file: .env`; o Compose injeta o arquivo completo em cada container. Por isso, conflitos ou variáveis compartilhadas permanecem sem renomeação.

## Versões das imagens

- PostgreSQL: `18.4`
- Redis: `8.10.0-alpine`
- RabbitMQ: `4.3.4-management`
- PgBouncer: `v1.25.2-p0`
- MinIO: `RELEASE.2025-09-07T16-13-09Z`
- RustFS: `1.0.0-beta.12`

O PostgreSQL 18 usa uma estrutura de volume diferente das versões 17 e anteriores. O Compose monta o volume em `/var/lib/postgresql`; não reutilize dados antigos sem executar o procedimento de upgrade/migração da documentação do PostgreSQL.

O repositório oficial do MinIO foi arquivado. A tag usada é a última imagem publicada verificável, não `latest`; avalie uma migração para RustFS ou outra distribuição suportada antes de um ambiente produtivo.

O RustFS executa como usuário não-root `10001:10001`. Volumes bind-mounted precisam ser graváveis por esse usuário. O bypass de checagem de disco permanece desativado (`false`); não o habilite fora de testes locais.

## Validação

```sh
docker compose --env-file .env -f docker-compose.yml config
```

O arquivo `.env.example` contém referências `${{ production.VARIABLE }}` do Dokploy e deve ser resolvido pelo Dokploy antes do uso; por isso ele não é um arquivo de entrada válido para o parser local do Docker Compose.
