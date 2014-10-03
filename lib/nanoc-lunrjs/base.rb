module NanocLunrjs
  def self.assets_path
    File.expand_path("../assets/", __FILE__)
  end

  def self.templates_path
    File.join(NanocLunrjs.assets_path, 'templates')
  end
end