# Ruby on Rails News

Server-rendered news site. Pages are HTML produced by Rails (MVC, ERB). The browser does not fetch a JSON API for the feed.

## Stack

- Ruby 3.4.10
- Rails 8.1
- PostgreSQL 16 (`pg`)
- Puma
- Propshaft for CSS
- Import maps, Turbo, Stimulus
- bcrypt for password hashes
- OmniAuth and `omniauth-facebook` for Facebook login
- RSpec, FactoryBot, Faker, shoulda-matchers

The `json` gem is pinned below 3. Version 3 breaks Rails 8.1 session cookies.

## Data model

PostgreSQL tables, defined by migrations and recorded in `db/schema.rb`.

| Table | Role |
|---|---|
| `rubrics` | `title`, `description`. A rubric owns many articles. |
| `articles` | `title`, `body`, required `rubric_id` foreign key and index. An article belongs to one rubric. |
| `users` | `login` (unique), `password_digest` (bcrypt, nullable), `provider`, `uid`. |
| `favorites` | Join table. `user_id` and `article_id`, both foreign keys. Unique index on `(user_id, article_id)`. `created_at` is the save time. |

Associations:

- `Rubric has_many :articles`
- `Article belongs_to :rubric` and `has_many :favorites`
- `User has_many :favorites` and `has_many :favorite_articles, through: :favorites`
- `Favorite belongs_to :user` and `belongs_to :article`

Deleting a user or an article destroys that row's favorites (`dependent: :destroy`).

## Features

### Home feed

`GET /` is `MainController#index`.

The page lists every rubric and the newest articles (`created_at DESC`, then `id DESC`). Rubrics are eager-loaded with `includes(:rubric)` so the list does not issue one query per card.

Each card links to `GET /articles/:id` (`ArticlesController#show`). That action loads one article with `Article.find`. A missing id returns 404. The page title is the article title. The layout masthead links back to `/`.

Empty lists render an explicit empty state.

### Rubric filter and search

The same `index` action builds the query from request params.

- `?rubric_id=` limits articles with `Article.by_rubric` (`where(rubric_id:)`). Rubric blocks are links to `/?rubric_id=`. The active rubric gets the `rubric--active` class. "All rubrics" clears the param.
- `?q=` searches `title` and `body` with PostgreSQL `ILIKE` and bound placeholders (`Article.search`). Matching is case-insensitive and substring-based (`%query%`).
- Both params apply together. The search form is `GET` and keeps the current `rubric_id` in a hidden field, so a search stays inside the selected rubric. The typed query is written back into the input.

Filter and search state lives in the URL.

### Infinite scroll

The first response is one page of 10 articles. A Stimulus controller (`infinite-scroll`) watches a sentinel with `IntersectionObserver` (240px root margin).

When the sentinel enters the viewport, the controller requests the next page:

`GET /?page=2&rubric_id=&q=` with `X-Requested-With: XMLHttpRequest`.

An XHR request renders only the article partials, without the layout. The response header `X-Has-More` is `1` or `0`. The client appends the HTML to the list. Rubric and search params stay on the request, so later pages match the current filter. Loading stops when no further row exists.

### Accounts

Reading the site does not require a login. The masthead shows a guest avatar (`?`) that links to `/login`. A signed-in user gets an account menu (`<details>` / `<summary>`): Favorites and Log out.

Registration and login are separate controllers.

- `GET/POST /signup` creates a `users` row (`login`, `password`, `password_confirmation`) and stores `session[:user_id]`.
- `GET/POST /login` finds the user by login and calls `authenticate`. A match stores `session[:user_id]`. A miss renders one error for a bad login or a bad password.
- `DELETE /logout` deletes `session[:user_id]`.

The password is not stored. `has_secure_password` writes a bcrypt hash into `password_digest`. Password length is at least 4 characters. Login is required and unique in the model and in a unique index.

`current_user` lives on `ApplicationController` and is exposed to views. It loads `User.find_by(id: session[:user_id])` once per request. Successful `POST` actions redirect with `303 See Other`.

### Facebook login

Facebook is a second way to obtain the same `users` row and the same `session[:user_id]`. Favorites, the avatar, and logout do not branch on how the user signed in.

Columns `provider` (`"facebook"`) and `uid` (Facebook's id, stored as a string) identify the external account. A unique index covers `(provider, uid)`. `password_digest` is nullable for these rows. Password validation still runs for ordinary signup (`provider` blank, on create).

The login page posts to `/auth/facebook` (`button_to`, `data-turbo="false"`, because OmniAuth must follow a full-page redirect to Facebook). OmniAuth middleware handles that `POST` when keys are present. Facebook returns the browser to `GET /auth/facebook/callback`. `OauthController#facebook` reads `request.env["omniauth.auth"]`, calls `User.from_omniauth`, and sets `session[:user_id]`.

`from_omniauth` finds or creates the user by `provider` and `uid`. The login is derived from the Facebook name only on create: non-letters become `_`, the value is trimmed to 40 characters, and a numeric suffix is appended while the login is taken. The requested scope is `public_profile` (name only).

If `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` are absent, the middleware is not installed and `POST /auth/facebook` redirects to login with "not configured". A failed callback hits `GET /auth/failure` and redirects to login with an alert.

Keys are read at boot from the environment, or from Rails credentials (`facebook.app_id`, `facebook.app_secret`). Changing them requires a server restart.

### Favorites

A favorite is a row in `favorites`, not a list of ids on the user. One user can save many articles. One article can be saved by many users. The pair cannot be stored twice (model validation and the unique index).

- `POST /articles/:article_id/favorite` creates the row for `current_user` (`find_or_create_by!`).
- `DELETE /articles/:article_id/favorite` destroys that user's row.
- `GET /favorites` lists the current user's articles, newest save first (`favorites.created_at DESC`), with rubrics eager-loaded.

`FavoritesController` requires a login. A guest who clicks the bookmark is sent to `/login`.

The bookmark is a partial used on the feed and on the article page. Turbo Streams replace that partial in place (`toggle.turbo_stream.erb`). A normal HTML request redirects back. Favorite article ids for the current user are loaded once per request and reused by every bookmark on the page.

## Seeds

`db/seeds.rb` replaces rubrics and articles with three rubrics (Спорт, Политика, Технологии) and 60 articles. Articles are deleted before rubrics because of the foreign key. Users and favorites are left in place.

## Tests

Specs cover models (associations, validations, search), the home controller (rubrics, filtered articles, the next infinite-scroll page), article show, signup, login, logout, Facebook callback, and favorites. Request specs assert the HTML, including which titles are present and which are absent.

Controller specs send a modern browser user agent. Rails 8 rejects older clients with 406.

## Run locally

PostgreSQL 16 must be installed and accepting connections. On macOS with Homebrew:

```bash
brew install postgresql@16
brew services start postgresql@16
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
```

Open a new shell so `psql` and `pg_isready` are on `PATH`. `bin/setup` also prepends the Homebrew `postgresql@16` bin directory when it finds one.

Development database: `ruby_on_rails_news_development`. Test database: `ruby_on_rails_news_test`. Both use the local PostgreSQL user. No password is set in `config/database.yml` for development.

Install gems, create the databases, and load the schema:

```bash
bin/setup --skip-server
bin/rails db:seed
bin/dev
```

`bin/setup` runs `bundle install`, checks that PostgreSQL answers `pg_isready`, then `bin/rails db:prepare`. Pass `--reset` to drop and recreate the databases and load seeds in one step: `bin/setup --reset --skip-server`.

Open [http://127.0.0.1:3000](http://127.0.0.1:3000).

Other commands:

```bash
bin/rails db:migrate    # apply new migrations
bin/rails db:seed       # load the 60 articles again
bin/rails c             # console
bundle exec rspec       # test suite
```

### Facebook login

Create a Meta app with the Facebook Login product. Set the OAuth redirect URI to:

```text
http://127.0.0.1:3000/auth/facebook/callback
```

Start the server with the app keys:

```bash
FACEBOOK_APP_ID=your_app_id FACEBOOK_APP_SECRET=your_app_secret bin/dev
```

Or store them in credentials (`bin/rails credentials:edit`):

```yaml
facebook:
  app_id: your_app_id
  app_secret: your_app_secret
```

Restart the server after either change. The Facebook button on `/login` then starts the OAuth redirect. Without keys, the rest of the site still runs, including login and password signup.
