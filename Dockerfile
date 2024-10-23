FROM index.docker.io/library/swift:5.9-jammy as builder
WORKDIR /src
COPY ./Package.* ./
COPY ./Sources ./Sources
COPY ./Resources ./Resources
COPY ./Tests ./Tests
RUN swift build -c release -Xswiftc -g
RUN mkdir /output
RUN cp $(swift build -c release -Xswiftc -g --show-bin-path)/SincereAuthServer /output/SincereAuthServer
RUN cp -R ./Resources /output/Resources

FROM index.docker.io/library/swift:5.9-jammy-slim as production
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY --from=builder /output/* /app/
COPY --from=builder /usr/lib/swift/ /usr/lib/swift/

FROM production as web
ENV PORT 80
EXPOSE $PORT
COPY ./Resources ./Resources
CMD /app/SincereAuthServer serve --env production --hostname 0.0.0.0 -p $PORT

FROM production as queues
CMD /app/SincereAuthServer queues --env production

FROM production as scheduled-queues
CMD /app/SincereAuthServer queues --scheduled --env production

FROM production as release
CMD /app/SincereAuthServer migrate -y --env production
