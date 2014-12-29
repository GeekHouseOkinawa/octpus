require 'gviz'

def remote_images_dir
  File.expand_path('remote_images', __dir__)
end

Dir.mkdir(remote_images_dir) unless Dir.exist?(remote_images_dir)

def remote_image(name, remote_image_url, ext = File.extname(remote_image_url))
  filename = File.expand_path("#{name}#{ext}", remote_images_dir)

  unless File.exist?(filename)
    system('wget', '-O', filename, remote_image_url)
  end

  if ext.downcase == '.svg'
    dest_filename = File.expand_path("#{name}.png", remote_images_dir)
    unless File.exist?(dest_filename)
      system('convert', '-density', '1200', '-resize', '200x200', filename, dest_filename)
    end
    filename = dest_filename
  end

  resized_filename = File.expand_path("#{name}_200x200.png", remote_images_dir)

  unless File.exist?(resized_filename)
    system('convert', '-resize', '200x200', filename, resized_filename)
  end

  define_method name do
    resized_filename
  end
end

remote_image :mark_github, 'https://raw.githubusercontent.com/github/octicons/master/svg/mark-github.svg'
remote_image :person,      'https://raw.githubusercontent.com/github/octicons/master/svg/person.svg'
remote_image :server,      'https://raw.githubusercontent.com/github/octicons/master/svg/server.svg'
remote_image :travis,      'https://raw.githubusercontent.com/travis-ci/travis-web/master/assets/images/travis-mascot-150.png'
remote_image :minecraft,   'http://hydra-media.cursecdn.com/minecraft.gamepedia.com/c/c5/Grass.png'
remote_image :creeper,     'http://hydra-media.cursecdn.com/minecraft.gamepedia.com/0/0a/Creeper.png'
remote_image :route53,     'http://upload.wikimedia.org/wikipedia/commons/c/c9/AWS_Simple_Icons_Networking_Amazon_Route_53.svg'
remote_image :heroku,      'http://upload.wikimedia.org/wikipedia/en/a/a9/Heroku_logo.png'
remote_image :idobata,     'http://www.gravatar.com/avatar/9fef32520aa08836d774873cb8b7df28?s=200'
remote_image :fluentd,     'https://raw.githubusercontent.com/fluent/website/master/logos/fluentd.png'
remote_image :nginx,       'http://upload.wikimedia.org/wikipedia/commons/c/c5/Nginx_logo.svg'

def icon_node(name, icon:, label: name.to_s, &block)
  node name, image: icon, label: '', shape: 'none'
  subgraph do
    global label: label, penwidth: 0, fontsize: 20
    node name
    instance_eval(&block) if block
  end
end

Graph do
  global overlap: false, nodesep: 1.1, rankdir: 'LR'
  icon_node :GitHub, icon: mark_github
  icon_node :TravisCI, icon: travis, label: '料理人'
  icon_node :Geek, icon: person, label: 'ギー沖住人　　　　　　'
  icon_node :Route53, icon: route53, label: 'Route 53'
  icon_node :ShyoboiDDNS, icon: heroku, label: 'しょぼいDDNS'

  subgraph do
    global label: 'タコ壷マシン', fontsize: 30, fontcolor: 'deeppink4', pencolor: 'deeppink4', style: 'bold', fontname: 'Hiragino Kaku Gothic Std'
    icon_node :Octpus, icon: minecraft, label: '鯖'
    icon_node :Bot, icon: creeper, label: 'Bot'
    icon_node :Map, icon: nginx, label: '地図配信鯖'
    node :Cron, label: 'cron', fillcolor: 'darkorchid2', style:'filled'
    node :Fluentd, image: fluentd, label: '', shape: 'none'
  end

  icon_node :Idobata, icon: idobata, label: 'idobata'

  edge :Geek_Route53, label: '鯖の場所を問い合わせ'
  # 調節 ><
  edge :Route53_Geek, label: '', color: 'white', style: 'none'

  edge :GitHub_TravisCI, label: 'レシピを料理人にお届け'
  edge :Geek_GitHub, label: 'レシピをpush'

  edge :TravisCI_Octpus, label: 'レシピにしたがって鯖を調理'
  edge :Geek_Octpus, label: 'TravisやGitHubが働いてない場合は自分で調理'

  edge :Geek_Octpus, label: "できあがった鯖を\nもぐもぐ"

  edge :ShyoboiDDNS_Route53, label: '鯖の場所を更新' #'受け取ったIPアドレスでminecraft.hanach.inのDNSレコードを更新'

  edge :Bot_Idobata, label: '井戸端場会議を監視', color: 'darkolivegreen3', fontcolor: 'chartreuse4'
  edge :Bot_Octpus, label: '鯖に井戸端会議を垂れ流す', color: 'darkolivegreen3', fontcolor: 'chartreuse4'

  edge :Fluentd_Octpus, label: '鯖の会話ログを監視', color: 'deepskyblue2', fontcolor: 'deepskyblue4'
  edge :Fluentd_Idobata, label: '鯖の会話を井戸端会議に垂れ流す', color: 'deepskyblue2', fontcolor: 'deepskyblue4'

  edge :Cron_ShyoboiDDNS, label: '居場所を通知', color: 'darkorchid2', fontcolor: 'darkorchid4'
  edge :Cron_Map, label: '定期的に鯖の地図を設置', color: 'darkorchid2', fontcolor: 'darkorchid4'

  edge :Geek_Map, label: '鯖の地図を見る'

  edge :Geek_Idobata, label: '井戸端会議する', minlen: 2

  save :architecture_diagram, :png
end
