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
  id: 1,
  question: "Ou se trouve Paris ?",
  time: 10
})

// Answer
client.emit("answer", {
  questionId: 1,
  answer: {
    lat: 10,
    long: 10
  }
})

// -- Timer finish

server.emit("result", {
  questionId: 1,
  solve: {
    lat: 10,
    long: 10
  },
  ranks: [
    {userId: 1, nickname: "Greg", score: 10},
    {userId: 2, nickname: "Ludow", score: 5},
    ...
  ],
  time: 10
})

// -- Timer finish

// -> GOTO "New question"
```

## Events

### Server

#### join-status

* `{bool|string}` `error`: `false` if join is accepted, else the error.

#### question

* `int` `id`: Question ID
* `string` `question`: Question
* `int` `time`: Time in seconds

#### result

* `int` `questionId`: Question ID
* `object` `solve`: Solve
  * `float` `lat`: Latitude
  * `float` `long`: Longitude
* `array` `ranking`: Scores of the last question.
  * `int` `userId`: User id
  * `string` `nickname`: User name
  * `int` `score`: Score
* `int` `time`: Time in seconds

### Client

#### join

* `string` `nickname`: User name

#### answer

* `int` `questionId`: Question ID
* `object` `answer`: Answer
  * `float` `lat`: Latitude
  * `float` `long`: Longitude
