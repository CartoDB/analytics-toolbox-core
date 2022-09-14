import de.heikoseeberger.sbtheader._
import java.time.Year

val scalaVersions = Seq("2.12.15")

val catsVersion       = "2.7.0"
val shapelessVersion  = "2.3.3" // to be compatible with Spark 3.1.x
val scalaTestVersion  = "3.2.11"
val jtsVersion        = "1.18.1"
val geomesaVersion    = "3.3.0"
val hivelessVersion   = "0.0.12"
val geotrellisVersion = "3.6.2"
val h3Version         = "4.0.0-rc1"

// GeoTrellis depends on Shapeless 2.3.7
// To maintain better compat with Spark 3.1.x and DataBricks 9.1 we need to depend on Shapeless 2.3.3
val excludedDependencies = List(
  ExclusionRule("com.chuusai", "shapeless_2.12"),
  ExclusionRule("com.chuusai", "shapeless_2.13")
)

def ver(for212: String, for213: String) = Def.setting {
  CrossVersion.partialVersion(scalaVersion.value) match {
    case Some((2, 12)) => for212
    case Some((2, 13)) => for213
    case _             => sys.error("not good")
  }
}

def spark(module: String) = Def.setting {
  "org.apache.spark" %% s"spark-$module" % ver("3.1.3", "3.2.1").value
}

// https://github.com/xerial/sbt-sonatype/issues/276
ThisBuild / sonatypeCredentialHost := "s01.oss.sonatype.org"

lazy val commonSettings = Seq(
  scalaVersion       := scalaVersions.head,
  crossScalaVersions := scalaVersions,
  organization       := "com.carto.analyticstoolbox",
  scalacOptions ++= Seq(
    "-deprecation",
    "-unchecked",
    "-language:implicitConversions",
    "-language:reflectiveCalls",
    "-language:higherKinds",
    "-language:postfixOps",
    "-language:existentials",
    "-feature",
    "-target:jvm-1.8" // ,
    // "-Xsource:3"
  ),
  licenses               := Seq("BSD-3-Clause" -> url("https://github.com/CartoDB/analytics-toolbox-databricks/blob/master/LICENSE")),
  homepage               := Some(url("https://github.com/CartoDB/analytics-toolbox-databricks")),
  versionScheme          := Some("semver-spec"),
  Test / publishArtifact := false,
  Test / fork            := true,
  developers := List(
    Developer(
      "pomadchin",
      "Grigory Pomadchin",
      "@pomadchin",
      url("https://github.com/pomadchin")
    )
  ),
  headerLicense := Some(HeaderLicense.ALv2(Year.now.getValue.toString, "Azavea")),
  headerMappings := Map(
    FileType.scala -> CommentStyle.cStyleBlockComment.copy(
      commentCreator = { (text, existingText) =>
        // preserve year of old headers
        val newText = CommentStyle.cStyleBlockComment.commentCreator.apply(text, existingText)
        existingText.flatMap(_ => existingText.map(_.trim)).getOrElse(newText)
      }
    )
  ),
  // resolver for hiveless SNAPSHOT dependencies
  resolvers += "oss-snapshots" at "https://oss.sonatype.org/content/repositories/snapshots",
  addCompilerPlugin("org.typelevel" % "kind-projector" % "0.13.2" cross CrossVersion.full),
  libraryDependencies += "org.scalatest" %% "scalatest" % scalaTestVersion % Test,
  // sonatype settings
  sonatypeProfileName    := "com.carto",
  sonatypeCredentialHost := "s01.oss.sonatype.org",
  sonatypeRepository     := "https://s01.oss.sonatype.org/service/local",

  // settings for the linter (scalaFIX)
  semanticdbEnabled := true, // enable SemanticDB
  semanticdbVersion := scalafixSemanticdb.revision, // only required for Scala 2.x
  scalacOptions += "-Ywarn-unused-import" // Scala 2.x only, required by `RemoveUnused`
)

lazy val root = (project in file("."))
  .settings(commonSettings)
  .settings(name := "analyticstoolbox")
  .settings(
    scalaVersion       := scalaVersions.head,
    crossScalaVersions := Nil,
    publish            := {},
    publishLocal       := {}
  )
  .aggregate(core, jts)

lazy val core = project
  .dependsOn(jts)
  .settings(commonSettings)
  .settings(name := "core")
  .settings(
    libraryDependencies ++= Seq(
      "com.azavea"               %% "hiveless-core"     % hivelessVersion,
      "org.locationtech.geomesa" %% "geomesa-spark-jts" % geomesaVersion,
      "com.uber"                  % "h3"                % h3Version,
        spark("hive").value         % Provided
    ) ++ Seq(
      "org.locationtech.geotrellis" %% "geotrellis-store"         % geotrellisVersion,
      "org.locationtech.geotrellis" %% "geotrellis-spark-testkit" % geotrellisVersion % Test
    ).map(_ excludeAll (excludedDependencies: _*)),
    assembly / test := {},
    assembly / assemblyShadeRules := {
      val shadePackage = "com.carto.analytics"
      Seq(
        ShadeRule.rename("shapeless.**" -> s"$shadePackage.shapeless.@1").inAll,
        ShadeRule.rename("cats.kernel.**" -> s"$shadePackage.cats.kernel.@1").inAll
      )
    },
    assembly / assemblyMergeStrategy := {
      case s if s.startsWith("META-INF/services")           => MergeStrategy.concat
      case "reference.conf" | "application.conf"            => MergeStrategy.concat
      case "META-INF/MANIFEST.MF" | "META-INF\\MANIFEST.MF" => MergeStrategy.discard
      case "META-INF/ECLIPSEF.RSA" | "META-INF/ECLIPSEF.SF" => MergeStrategy.discard
      case _                                                => MergeStrategy.first
    }
  )

lazy val jts = project
  .settings(commonSettings)
  .settings(name := "hiveless-jts")
  .settings(libraryDependencies += "org.locationtech.jts" % "jts-core" % jtsVersion)
