# TODO

## Security

- [ ] Move hardcoded Pusher credentials to environment variables (`config/initializers/pusher.rb`). The app_id and key are semi-public (frontend uses them), but the secret must not be in source control.
