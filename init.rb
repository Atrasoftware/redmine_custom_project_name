Redmine::Plugin.register :redmine_custom_project_name do
  name 'Redmine Custom Project Name plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.2'
  url 'https://github.com/Atrasoftware/redmine_custom_project_name'

  settings :default=>{
        :sortable_position=>''
   }, :partial => 'settings/setting_rcpn'
end

Rails.application.config.to_prepare do
  Query.send(:include, Patches::QueryPatch)
  Project.send(:include, Patches::ProjectPatchCf)
  ApplicationHelper.send(:include, Patches::ApplicationHelperPatch)
  Mailer.send(:include, Patches::MailerPatch)
  SettingsController.send(:include, Patches::SettingsControllerPatch)
end