# Task Manager Backend

## Technology Stack

- Frontend  :Next.js
- Backend   :Express.js
- Database  :MongoDB


## Overview

This repository contains the Node.js and Express API for the Task Manager application. It connects to MongoDB, authenticates users with JWTs stored in cookies, and provides authentication, task, and user endpoints under `/api`.

The project also includes deployment files for Docker, Docker Compose, Nginx, and Terraform. Each file has a separate responsibility, described below.

## Prerequisites

- Node.js 22 or a current LTS release
- npm
- A MongoDB database
- Docker and Docker Compose for containerized deployment
- Terraform and AWS credentials for infrastructure provisioning

## Configuration

Create a `.env` file in the project root:

```env
MONGODB_URI=mongodb://localhost:27017/taskmanager
NODE_ENV=development
JWT_SECRET=replace-with-a-long-random-secret
PORT=3001
```

Do not commit real database credentials or JWT secrets. Keep `.env` local and use your deployment platform's secret configuration in production.

## Local Setup

Install dependencies:

```bash
npm install
```

Start the development server with automatic restart:

```bash
npm run dev
```

The API listens on `http://localhost:3001` unless `PORT` is set.

## Database Seeding

The seed script is located at `src/seed.js`, not in the project root. Run it from the repository root with:

```bash
node src/seed.js
```

It connects to MongoDB, creates the default administrator when that email does not already exist, and skips an existing administrator.

The default seed account is:

```text
Email: admin@email.com
Password: k123
Role: ADMIN
```

Change this password after the first login, and do not use the sample credentials in a public deployment.

## API Routes

The API prefix is `/api`.

| Area | Base path | Access |
| --- | --- | --- |
| Authentication | `/api/auth` | Public login and registration routes |
| Tasks | `/api/tasks` | Authenticated users |
| Users | `/api/users` | Authenticated users, with role checks where configured |

### Subtasks

Tasks include `subtasks`, an array of objects shaped like `{ task, checked }`.
The task creator, task assignee, and any administrator can manage a task's
subtasks. Other authenticated users receive `403 Forbidden`.

| Operation | Method | Path | Body |
| --- | --- | --- | --- |
| Add subtask | `POST` | `/api/tasks/:id/subtasks` | `{ "task": "Write tests", "checked": false }` |
| Check or edit subtask | `PATCH` | `/api/tasks/:id/subtasks/:subtaskId` | `{ "checked": true }` or `{ "task": "Updated text" }` |
| Remove subtask | `DELETE` | `/api/tasks/:id/subtasks/:subtaskId` | None |

## Deployment Files

### Dockerfile

`Dockerfile` builds the backend image:

1. Starts from the Node.js LTS Alpine image.
2. Installs production dependencies with `npm ci --omit=dev`.
3. Copies the application source into `/app`.
4. Exposes port `3001`.
5. Starts `src/server.js`.

Build and run the backend image:

```bash
docker build -t taskmanager-backend .
docker run --rm -p 3001:3001 --env-file .env taskmanager-backend
```

### docker-compose.yml

`docker-compose.yml` runs the published backend and frontend images together:

- Backend: host port `3001` to container port `3001`
- Frontend: host port `3000` to container port `3000`
- Backend environment variables: `MONGODB_URI`, `NODE_ENV`, and `JWT_SECRET`

Create or update the root `.env` file, then start the stack:

```bash
docker compose up -d
```

View service logs or stop the stack:

```bash
docker compose logs -f backend
docker compose down
```

The Compose file references the published images `kavinduishara/taskmanager-backend:latest` and `kavinduishara/taskmanager-frontend:latest`. Change those image names when using a different registry.

### nginx.config

`nginx.config` is a reverse-proxy configuration for `pmtool.ddnsking.com`:

- `https://pmtool.ddnsking.com/api/` forwards to the backend on `127.0.0.1:3001`.
- Other paths forward to the frontend on `127.0.0.1:3000`.
- HTTP traffic is redirected to HTTPS.
- TLS certificate paths are managed by Certbot.

Before using this file on another server, update the domain, upstream addresses, and certificate paths. Nginx must be able to reach both application containers or services.

### Terraform

The `terraform/` directory provisions AWS infrastructure in `us-east-1`:

- A VPC with DNS support
- A public subnet and internet gateway
- A public route table
- A security group allowing SSH (`22`), HTTP (`80`), and HTTPS (`443`)
- A `t3.micro` Ubuntu 24.04 EC2 instance

Initialize and review the infrastructure plan:

```bash
cd terraform
terraform init
terraform plan
```

Apply it only after reviewing the plan:

```bash
terraform apply
```

Terraform outputs the VPC ID, subnet ID, EC2 instance ID, and public IP. The instance uses the AWS key pair named `project-manager-server-key`, which must already exist in `us-east-1`.

Destroy the provisioned resources when they are no longer needed:

```bash
terraform destroy
```

Do not commit Terraform state files containing infrastructure details or credentials. Use remote state and state locking for shared or production environments.

## Troubleshooting

### `Cannot find module ...\\seed.js`

Run the script using its actual path:

```bash
node src/seed.js
```

### MongoDB connection fails

Check that `MONGODB_URI` is present, valid, and allows the current machine or server IP address. For Docker Compose, confirm the variable is available in the root `.env` file.

### Port already in use

Stop the process using port `3001`, or set another `PORT` for a local Node.js process. When using Compose, update the host-side port mapping if necessary.

### Nginx returns `502 Bad Gateway`

Confirm that the backend and frontend are running on ports `3001` and `3000`, then verify that the Nginx upstream addresses are reachable from the Nginx host.

## References

- [Express](https://expressjs.com/)
- [Mongoose](https://mongoosejs.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Nginx reverse proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
