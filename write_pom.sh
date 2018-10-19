if [ "$#" -ne 3 ]; then
    echo "write_pom.sh <groupId> <artifactId> <version>"
    exit 1
fi
cat <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>$1</groupId>
  <artifactId>$2</artifactId>
  <version>$3</version>
</project>
EOL
