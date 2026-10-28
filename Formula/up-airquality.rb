class UpAirquality < Formula
  desc "Self-hosted collector and dashboard for the UniFi UP-AirQuality sensor"
  homepage "https://github.com/ToasteezStudio/up-airquality"
  # url and sha256 are updated automatically when a release is published.
  url "https://github.com/ToasteezStudio/up-airquality/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "82ddeb77e5461686924c70121de34ddec94cb19289450cc9b7813003e204c1f3"
  license "PolyForm-Noncommercial-1.0.0"
  head "https://github.com/ToasteezStudio/up-airquality.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  # `brew services start up-airquality` runs the console + dashboard for a
  # sensor that has already been adopted to this Mac (see `up-airquality run`).
  # Homebrew can't know the sensor's IP, so the service runs without --host
  # and accepts any address; the caveats explain the stricter alternative.
  # Dashboard: http://localhost:8099/
  service do
    run [opt_bin/"up-airquality", "serve"]
    keep_alive true
    log_path var/"log/up-airquality.log"
    error_log_path var/"log/up-airquality.log"
  end

  def caveats
    <<~EOS
      Adopt your sensor to this Mac once (this changes the sensor's state):
        up-airquality --host <SENSOR_IP> run

      After that, run the collector in the background with:
        brew services start up-airquality

      Note: the background service runs without --host, so it accepts sensor
      connections from any device on your network (it logs a warning). To
      accept only your sensor, run it yourself instead:
        up-airquality --host <SENSOR_IP> serve

      Dashboard: http://localhost:8099/
      macOS may ask to allow incoming connections; allow it so the sensor
      can reach tcp/7442.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/up-airquality --version")
    assert_match "--host", shell_output("#{bin}/up-airquality info 2>&1", 1)
  end
end
