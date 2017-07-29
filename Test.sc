import scala.io.Source

def test(file: String, expectedLines: List[String]): Unit = {
  val bufferedSource = Source.fromFile(file, "UTF-8")
  val lines = bufferedSource.getLines.toList
  bufferedSource.close()
  expectedLines.foreach { s =>
    assert(lines.contains(s))
  }
}

@main
def main() = {
  test("./etc/php/conf.d/docker-php-ext-apcu.ini", List(
    "apc.shm_size=96M",
    "apc.entries_hint=26000"
  ))

  test("./etc/php-fpm.d/www.conf", List(
    "pm.max_children = 200",
    ";pm.start_servers = 2",
    "pm.min_spare_servers = 5",
    "pm.max_spare_servers = 25",
    "pm.status_path = /status",
    "ping.path = /ping"
  ))
}
