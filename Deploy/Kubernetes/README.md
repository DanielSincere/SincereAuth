# Digital Ocean Kubernetes

Deployment guide for SincereAuth on Digital Ocean Kubernetes

## Pre reqs

1. A Kubernetes cluster
2. A Postgres instance, accessible from the cluster

## Install

1. Create a user in the database for SincereAuth. Ensure this user has access to the `public` schema. If your user doesn't have access, login to your sincereauth database as your root user and grant access. For example,

   GRANT ALL ON SCHEMA public TO sincereauth;

2. Gather the other environment variables as discussed in `Sources/SincereAuthServer/EnvVars.swift`, and store them in the secrets file. Rename 1-sincereauth-secrets.sample.yml to 1-sincereauth-secrets.yml.

- APPLE_APP_ID
- ADDITIONAL_APPLE_APP_IDS
- APPLE_SERVICES_KEY
- APPLE_SERVICES_KEY_ID
- APPLE_TEAM_ID
- AUTH_PRIVATE_KEY
- DB_SYMMETRIC_KEY
- DATABASE_URL
- REDIS_URL
- SELF_ISSUER_ID
- WEBSITE_APPLE_APP_ID
- WEBSITE_URL

3. Deploy the App

   kubectl apply -Rf Deploy/Kubernetes/

4. Set up ingress resources in your cluster and load balancer

5. After you login the first time, you may manually add the admin role to your user in the database, as that's not supported yet in the UI.

   UPDATE `USER` SET roles = '{"admin"}'::text[]
