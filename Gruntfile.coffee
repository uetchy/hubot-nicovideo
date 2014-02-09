module.exports = (grunt) ->
  'use strict'

  # Initialize config
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    # Cleaning
    clean:
      js:
        src: 'src/**/*.js'
        test: 'test/*.js'

    # Watching files
    watch:
      coffee:
        files: ['src/**/*.coffee', 'test/*.coffee'],
        tasks: ['coffee']

    # Coffee コンパイル
    coffee:
      dist:
        files: [
          expand: true
          cwd: 'src'
          src: '*.coffee'
          dest: 'src'
          ext: '.js'
        ]
      src_lib:
        files: [
          expand: true
          cwd: 'src/lib'
          src: '*.coffee'
          dest: 'src/lib'
          ext: '.js'
        ]
      test:
        files: [
          expand: true
          cwd: 'test'
          src: '*.coffee'
          dest: 'test'
          ext: '.js'
        ]
      



  # Load global tasks
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  # Register tasks
  grunt.registerTask 'default', ['watch']