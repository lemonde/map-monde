var _ = require('lodash'),
  async = require('async');

// Create a new Game
// io : Socket io instance
// questionProvider (callback) : A function that return the question in a callback
// scoreComputer (solve, answer) : Return a score
// pauseTime : Time between two questions
var Game = function (options) {
  this.io = options.io;
  this.questionProvider = options.questionProvider;
  this.scoreComputer = options.scoreComputer;
  this.pauseTime = options.pauseTime;
  this.currentQuestion = null;
  this.users = [];
  this.answers = [];
  this.answersByUser = {};
};

Game.prototype = {
  // Start the game
  start: function () {
    this.io.sockets.on('connection', this.onConnect.bind(this));
    this.routine();
    return this;
  },

  log: function () {
    console.log.apply(null, ['--- GAME'].concat(_.toArray(arguments)));
  },

  // Routine
  routine: function () {
    var self = this;

    this.log('start routine');

    async.series([
      // Ask question
      this.askQuestion.bind(this),
      // Wait question time
      function (cb) {
        self.log('wait question time', self.currentQuestion.time);
        setTimeout(cb, self.currentQuestion.time * 1000);
      },
      // Send result
      this.sendResult.bind(this),
      // Wait pause time
      function (cb) {
        self.log('wait pause time', self.pauseTime);
        setTimeout(cb, self.pauseTime * 1000);
      }
    ], this.routine.bind(this));
  },

  // When a new client is connected
  onConnect: function (socket) {
    var self = this;

    socket.on('join', function (data) {
      self.registerUser(data, socket);
    });

    socket.on('answer', function (data) {
      self.handleAnswer(data, socket);
    });
  },

  // Register a new user
  registerUser: function (data, socket) {
    var userId = this.users.push(data.nickname) - 1;
    this.log('add user', data.nickname);
    this.log('currents users', this.users);

    socket.set('userId', userId, function () {
      var data = {error: false};
      this.log('emit "join-status"', data);
      socket.emit('join-status', data);
    }.bind(this));
  },

  // Handle an answer
  handleAnswer: function (data, socket) {
    socket.get('userId', function (err, userId) {
      if (err || ! userId)
        return ;

      if (! this.currentQuestion || this.currentQuestion.id !== data.questionId)
        return ;

      this.answers.push(_.extend(data, {
        userId: userId
      }));
    }.bind(this));
  },

  // Ask a new question
  askQuestion: function (callback) {
    this.questionProvider(function (question) {
      this.currentQuestion = question;
      this.answers = [];
      this.answersByUser = {};
      var clientQuestion = {
        id: question.id,
        question: question.question,
        time: question.time
      };
      this.log('emit "question"', clientQuestion);
      this.io.sockets.emit('question', clientQuestion);
      callback();
    }.bind(this));
  },

  // Envoi du résultat
  sendResult: function (callback) {

    if (! this.currentQuestion)
      return ;

    var scoredAnswers = _.map(this.answers, function (answer) {
      return _.extend(answer, {
        score: this.scoreComputer(this.currentQuestion.solve, answer.answer)
      });
    }, this).sort(function (a, b) {
      return a.score < b.score;
    });


    var result = {
      questionId: this.currentQuestion.id,
      solve: this.currentQuestion.solve,
      ranking: _.map(scoredAnswers, function (answer) {
        return {
          userId: answer.userId,
          nickname: this.users[answer.userId],
          score: answer.score
        };
      }.bind(this)),
      time: this.pauseTime
    };

    this.log('emit "result"', result);
    this.io.sockets.emit('result', result);
    callback();
  }
};

exports = module.exports = function (options) {
  var game = new Game(options);
  return game.start();
};

exports.Game = Game;