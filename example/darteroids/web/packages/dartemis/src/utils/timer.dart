part of dartemis;

abstract class Timer {
  final int delay;
  final bool repeat;
  int _acc;
  bool _done;
  bool _stopped;

  Timer(this.delay, this.repeat);

  void update(int delta) {
    if (!_done && !_stopped) {
      _acc += delta;

      if (_acc >= delay) {
        _acc -= delay;

        if (repeat) {
          reset();
        } else {
          _done = true;
        }

        execute();
      }
    }
  }

  void reset() {
    _stopped = false;
    _done = false;
    _acc = 0;
  }

  bool get done {
    return _done;
  }

  bool get running {
    return !_done && _acc < delay && !_stopped;
  }

  void stop() {
    _stopped = true;
  }


  void execute();

  double getPercentageRemaining() {
    if (_done) {
      return 100.0;
    } else if (_stopped) {
      return 0.0;
    } else {
      return 1 - (delay - _acc) / delay;
    }
  }

}
