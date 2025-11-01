{
  dockerTools,
  nodejs14-bin,
}:

dockerTools.buildImage {
  name = "nodejs14-bin-image";
  tag = "latest";

  copyToRoot = [
    nodejs14-bin
  ];
}
