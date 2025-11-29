# BookReview
 * Ruby version: 3.4.7
 * Rails version: 8.1.1

You can use docker compose in order to run this app, specs and rubocop.

To run the test you need to run:
```
docker compose run --rm app bundle exec rspec
```
To run rubocop you need to run:
```
docker compose run --rm app bundle exec rubocop
```

You can run the app in case you need to connect a frontend by running:

```
docker compose up
```

If you want to run it without Docker, make sure you meet the requirements listed in Dockerfile.dev. Then you can run:
```
bundle install
rake db:migrate
bundle exec rspec
bundle exec rubocop
rails server
```

And use `ctrl+C` to stop the rails server