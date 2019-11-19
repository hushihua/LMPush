Pod::Spec.new do |spec|
  spec.author       = "Lema"
  spec.name         = "LMPush"
  spec.version      = "1.0.0"
  spec.summary      = "乐马推送"
  spec.description  = "乐马推送SDK"
  spec.homepage     = "https://github.com/hushihua/LMPush"
  spec.license      = { :type => "Commercial", :text => "@2019 Lema.cm" }
  spec.author       = { "Adam.Hu" => "adam.hu.2018@gmail.com" }
  spec.source       = { :http => "https://github.com/hushihua/LMPush/tree/master/Sources/LMPush1.0.0.zip" }
  spec.requires_arc = true
  spec.ios.deployment_target = "10.0"
  spec.vendored_frameworks = "LMPush"
end
