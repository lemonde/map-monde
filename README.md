# Le jeu de vos rêves

## Game cycle

```js
// Join
client.emit("join", {
  nickname: "Greg"
})

server.emit("join-status", {
  success: true
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
