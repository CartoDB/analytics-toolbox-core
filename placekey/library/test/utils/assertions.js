function almostEquals(x, y, epsilon = 0.001) {
  return Math.abs(x - y) < epsilon;
}

function assertAlmostEqual(t, actual, expected, epsilon = 0.001, msg) {
  t.ok(almostEquals(actual, expected, epsilon), `${msg} ${actual} vs ${expected}`);
}
