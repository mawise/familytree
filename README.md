# Family Tree

I tried using Gramps, but it was too complex so I wrote my own?

## Deployment Notes

* Deploy as a standard rails app. Uses SQlite even in production

* Currently uses `dotenv` to store config in a dot file

* Expects S3 storage (for image uploads), specify bucket in `.env` file

* You need to manually create user accounts from the rails console:
  * `User.create! email: "user@email.com", password:"123456"`

* Uses graphviz for generating graphs, make sure your system has graphviz installed

## Deployment with Docker

### Prerequisites

* Docker
* Docker Compose

### Configuration

Create a `.env` file in the root directory with the following variables:

```
AWS_BUCKET=your-bucket-name
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
SECRET_KEY_BASE=your-secret-key-base
```

You can generate a `SECRET_KEY_BASE` by running:

```bash
docker-compose run --rm web bundle exec rails secret
```

### Database Setup

On the first run, you need to set up the database:

```bash
docker-compose run --rm web bundle exec rails db:setup
```

### Running with Docker

**Development:**

```bash
docker-compose up
```

The application will be available at `http://localhost:3000`. The source code is mounted as a volume, so changes will be reflected immediately (except for Gemfile changes which require rebuilding).

**Production:**

To run in production mode:

1.  Precompile assets:
    ```bash
    docker-compose run --rm -e RAILS_ENV=production web bundle exec rails assets:precompile
    ```

2.  Start the server:
    ```bash
    RAILS_ENV=production docker-compose up
    ```

The SQLite database will be persisted in a Docker volume named `sqlite_data` (mapped to `/data/production.sqlite3` inside the container).

**Building the image:**

```bash
docker-compose build
```

**Running Tests:**

```bash
docker-compose run --rm web bundle exec rake test
```
