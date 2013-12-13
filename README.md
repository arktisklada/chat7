# Rails 4 + MongoDB + Redis Chat Server

This is an experiement and working example of Rails 4 ActionController::Live, the Puma web server, and Redis.

## Features

- Puma multi-threaded rails server supports multple open connections
- **MongoDB** stores all the data (users and chat history)
- A reverse infinite scroll allows users to view the chatroom history
- **Redis** is used to establish a communication between threads
- There is a connection monitor in the top right corner
- Foundation was used to help support device responsiveness
- A member list is maintained of all users currently in the room

## Desired features / next steps

- 1:1 messaging
- Multple rooms
- Scalability


One of the biggest challenges in building this was overcoming the lingering open connections after a user has closed or refreshed the page.  In an effort to mitigate this, the app works with a 5-second "heartbeat" that closes any connections that have gone stale during that interval.

Any thoughts, comments, etc. just let me know!
