/*jshint undef:false */

var chai = require('chai'),
  sinon = require('sinon'),
  sinonChai = require('sinon-chai'),
  Game = require('../server/game').Game,
  events = require('events');

chai
  .use(sinonChai)
  .should();

describe('Game', function () {

  var io, socket, game;

  beforeEach(function () {
    // Mock io
    io = {
      sockets: new events.EventEmitter()
    };

    // Mock socket
    socket = new events.EventEmitter();
    socket.data = {};
    socket.set = function (field, val, callback) {
      this.data[field] = val;
      callback();
    };
    socket.get = function (field, callback) {
      callback(null, this.data[field]);
    };

    // Start game
    game = new Game({
      io: io,
      questionProvider: function () {
        return {id: 1, question: 'Where is Paris ?', time: 10};
      }
    });
    game.start();

    // Emit connection
    io.sockets.emit('connection', socket);
  });

  describe('#registerUser', function () {

    it('should add user to users', function () {
      game.registerUser({nickname: 'Greg'}, socket);
      game.users.should.have.members(['Greg']);
    });

    it('should emit ("join-status", {error: false})', function () {
      var joinStatusSpy = sinon.spy();
      socket.on('join-status', joinStatusSpy);

      game.registerUser({nickname: 'Greg'}, socket);
      joinStatusSpy.should.be.calledWith({error: false});
    });

    it('should register userId in the socket', function () {
      game.registerUser({nickname: 'Greg'}, socket);
      socket.data.should.have.property('userId', 0);
    });
  });

  describe('#askQuestion', function () {
    beforeEach(function () {
      game.questionProvider = function (callback) {
        callback({id: 1, question: 'Where is Paris ?', time: 10, solve: 'ok'});
      };
    });

    it('should emit a "question" event', function (done) {
      var questionSpy = sinon.spy();
      io.sockets.on('question', questionSpy);

      game.askQuestion(function () {
        questionSpy.should.be.calledWith({id: 1, question: 'Where is Paris ?', time: 10});
        done();
      });

    });

    it('should set the current question', function (done) {
      game.askQuestion(function () {
        game.currentQuestion.should.deep.equal({id: 1, question: 'Where is Paris ?', time: 10, solve: 'ok'});
        done();
      });
    });

    it('should reset answers', function (done) {
      game.answers = ['A'];
      game.answersByUser = {
        foo: 'bar'
      };

      game.askQuestion(function () {
        game.answersByUser.should.deep.equal({});
        game.answers.should.deep.equal([]);
        done();
      });
    });
  });

  describe('#handleAnswer', function () {
    it('should do nothing if the questionId is not equal to the current question id', function () {
      game.handleAnswer({
        questionId: 1,
        answer: {
          lat: 1,
          long: 1
        }
      }, socket);

      game.answers.should.deep.equal({});
    });

    it('should do nothing if the userId is not defined in the socket', function () {
      game.currentQuestion = {id: 1};

      game.handleAnswer({
        questionId: 1,
        answer: {
          lat: 1,
          long: 1
        }
      }, socket);

      game.answers.should.deep.equal({});
    });

    it('should add answer to answers if the questionId is equal to the current question id', function () {
      socket.data.userId = 5;

      game.currentQuestion = {id: 1};

      game.handleAnswer({
        questionId: 1,
        answer: {
          lat: 1,
          long: 1
        }
      }, socket);

      game.answers.should.deep.equal([
        {
          userId: 5,
          questionId: 1,
          answer: {
            lat: 1,
            long: 1
          }
        }
      ]);
    });
  });

  describe('#sendResult', function () {
    it('should emit a "result" event', function () {
      game.pauseTime = 10;

      game.currentQuestion = {
        id: 1,
        question: 'Ou se trouve Paris ?',
        solve: {
          lat: 2,
          long: 1
        }
      };

      game.scoreComputer = function (solve, answer) {
        return answer.lat;
      };

      game.users = [
        'Greg',
        'José'
      ];
      game.answers = [
        {
          userId: 0,
          questionId: 1,
          answer: {
            lat: 1,
            long: 1
          }
        },
        {
          userId: 1,
          questionId: 1,
          answer: {
            lat: 2,
            long: 1
          }
        }
      ];

      var resultSpy = sinon.spy();
      io.sockets.on('result', resultSpy);

      game.sendResult();

      resultSpy.should.be.calledWith({
        questionId: 1,
        solve: { lat: 2, long: 1 },
        ranking:
         [ { userId: 1, nickname: 'José', score: 2 },
           { userId: 0, nickname: 'Greg', score: 1 } ],
        time: 10
      });

    });
  });

});