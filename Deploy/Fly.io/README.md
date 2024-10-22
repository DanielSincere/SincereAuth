# FlyIO

## Setup infrastructure

1. Provision a Postgres database
2. Provision a Redis instance

## Setup SincereAuth

1. Clone the SincereAuth repo.
2. Set environment variables using `flyctl secrets set MY_SECRET=value`

- `AUTH_PRIVATE_KEY`: Base64. Output of `swish generate-jwt-key`
- `DB_SYMMETRIC_KEY`: output of `swish generate-db-key`
- `SELF_ISSUER_ID`: Custom name of your issuer. For example: `com.fullqueuedeveloper.MyAppServer`
- `APPLE_SERVICES_KEY`: Base64. Create under `Certificates, Identifiers & Profiles` > `Keys` or find here https://developer.apple.com/account/resources/authkeys/list
- `APPLE_SERVICES_KEY_ID`: ID of the `APPLE_SERVICES_KEY`
- `APPLE_TEAM_ID`: your Apple team ID. Looks like `ARST1234`
- `APPLE_APP_ID`: the bundle ID of your app. Looks like `com.fullqueuedeveloper.FQAuthSample
- `ADDITIONAL_APPLE_APP_IDS`: App Store Connect App Bundle IDs for secondary apps in your app group, delimited by spaces
- `DATABASE_URL`: the URL to your Postgres database
- `REDIS_URL`: the URL to your Redis instance
- `RUN_SCHEDULED_QUEUES_IN_MAIN_PROCESS` - When limited in number of process, you may run the scheduled queues in-process by setting this variable to `YES`. If you can only run one extra process, prioritize the regular queues variable (the other one).
- `RUN_QUEUES_IN_MAIN_PROCESS` - When limited in number of process, you may run the queues in-process by setting this
  variable to `YES`. If you can only run one extra process, prioritize the regular queues variable (this one).
- `RUN_AUTO_MIGRATE` - When limited in number of process, you may run the database in-process by setting this variable to `YES`. This is only safe when you are only running 1 replica of the main app process.

3. `fly deploy`
4. After you login the first time, you may manually add the admin role to your user in the database, as that's not supported yet in the UI.

   UPDATE `USER` SET roles = '{"admin"}'::text[]
