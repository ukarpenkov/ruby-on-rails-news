# Ruby on Rails News

Учебный новостной сайт на Ruby on Rails.

## Stack

- Ruby 3.4
- Rails 8.1
- PostgreSQL 16

## Setup

Install and start PostgreSQL (macOS / Homebrew):

```bash
brew install postgresql@16
brew services start postgresql@16
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
```

Then install gems and prepare the database:

```bash
bin/setup
bin/dev
```

Open [http://127.0.0.1:3000](http://127.0.0.1:3000).
