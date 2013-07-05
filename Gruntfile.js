'use strict';

var path = require('path');

module.exports = function (grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    express: {
      dev: {
        options: {
          port: 3000,
          hostname: 'localhost',
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
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-express');

  grunt.registerTask('server', ['express', 'watch:scripts']);
};