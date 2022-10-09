FROM ghcr.io/fullqueuedeveloper/fqauth:sha-9f33b943a946585ba449250e0f3f250482f3c623
ENV PORT 80
EXPOSE $PORT
CMD /app/FQAuthServer serve --env production --hostname 0.0.0.0 -p $PORT

FROM production as worker
CMD /app/FQAuthServer queues --env production

FROM production as release
CMD /app/FQAuthServer migrate -y --env production
