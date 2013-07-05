# map-monde

Amazing quiz game by THE WIN TEAM (Mr A, Mr G, Mr JH, Mr L)

## Start server

```
grunt server
```

## Game cycle

```js
// Join
client.emit("join", {
  nickname: "Greg"
})

server.emit("join-status", {
  error: false
})

// New question
server.emit("question", {
   question: "Ou se trouve Paris ?",
   timer: 10
})

// Answer
client.emit("answer", {
  lat: 10,
  long: 10
})

// -- Timer finish

server.emit("result", {
  lat: 10,
  long: 10,
  ranks: [
    {nickname: "Greg", score: 10},
    {nickname: "Ludow", score: 5},
    ...
  ],
  timer: 10
})

// -- Timer finish

// -> GOTO "New question"
```

## Events

### Server

#### join-status

* `{bool|string}` `error`: `false` if join is accepted, else the error.

#### question

* `string` `question`: Question
* `int` `timer`: Timer in seconds

#### result

* `float` `lat`: Latitude
* `float` `long`: Longitude
* `array` `ranking`: Scores of the last question.
  * `string` `nickname`: User name
  * `int` `score`: Score
* `int` `timer`: Timer in seconds

### Client

#### join

* `string` `nickname`: User name

#### answer

* `float` `lat`: Latitude
* `float` `long`: Longitude
