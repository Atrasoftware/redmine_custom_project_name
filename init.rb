Redmine::Plugin.register :redmine_custom_project_name do
  name 'Redmine Custom Project Name plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/Atrasoftware/redmine_custom_project_name'

  settings :partial => 'settings/setting_rcpn'
end
Rails.application.config.to_prepare do
  Query.send(:include, Patches::QueryPatch)
end