'use strict';

var path = require('path');

module.exports = function (grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    express: {
      dev: {
        options: {
          port: 3000,
          server: path.resolve('./config/server')
        }
      }
    },

    watch: {
      scripts: {
        files: ['server/**/*', 'config/**/*'],
        tasks: ['express'],
        options: {
          nospawn: true
        }
      }
    },

    simplemocha: {
      all: {
        src: ['test/**/*']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-express');
  grunt.loadNpmTasks('grunt-simple-mocha');

  grunt.registerTask('server', ['express', 'watch:scripts']);
  grunt.registerTask('server:simple', ['express', 'express-keepalive']);
  grunt.registerTask('test', ['simplemocha']);
};