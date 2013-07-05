// To define time: $scope.timerTime = 10;
// To start timer: $scope.$broadcast('timer:start')
window.angular.module('timer', [])
  .directive('timer', function () {
    return {
      link: function (scope, el) {
        var time,
          intervalTick = 20,
          interval;

        var progress = new window.CircularProgress({
          radius: 30,
          strokeStyle: '#3f6067',
          lineWidth: 10,
          initial: {
            strokeStyle: '#eee5de',
            lineWidth: 10
          },
          text: {
            font: 'bold 20px verdana',
            fillStyle: '#3f6067'
          }
        });

        el.append(progress.el);

        function render (text) {
          if (time < 2) {
            progress.options.strokeStyle = '#dd5f7a';
            progress.options.text.fillStyle = '#dd5f7a';
          }
          progress.options.text.value = text || Math.ceil(time);
          progress.update(time / scope.timerTime * 100);
        }

        scope.$on('timer:start', function () {
          clearInterval(interval);

          time = scope.timerTime;

          interval = setInterval(function () {
            time -= intervalTick / 1000;
            render();

            if (Math.ceil(time) === 0) {
              clearInterval(interval);
              render('-');
            }

          }, intervalTick);

          render();
        });
      }
    };
  });