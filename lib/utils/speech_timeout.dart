bool shouldStopListening(Duration elapsed, Duration timeout) {
  return elapsed >= timeout;
}
