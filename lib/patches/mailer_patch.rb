require_dependency 'mailer'

module  Patches
  module MailerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :issue_add ,:change
        alias_method_chain :issue_edit ,:change
        alias_method_chain :document_added ,:change

        alias_method_chain :attachments_added ,:change
        alias_method_chain :news_added ,:change
        alias_method_chain :news_comment_added ,:change

        alias_method_chain :message_posted ,:change
        alias_method_chain :wiki_content_added ,:change
        alias_method_chain :wiki_content_updated ,:change
        
      end
    end

  end
  module ClassMethods
  end

  module InstanceMethods
    def issue_add_with_change(issue, to_users, cc_users)
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id issue
      references issue
      @author = issue.author
      @issue = issue
      @users = to_users + cc_users
      @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
      mail :to => to_users.map(&:mail),
           :cc => cc_users.map(&:mail),
           :subject => "[#{issue.project.to_s} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
    end

    def issue_edit_with_change(journal, to_users, cc_users)
      issue = journal.journalized
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id journal
      references issue
      @author = journal.user
      s = "[#{issue.project.to_s} - #{issue.tracker.name} ##{issue.id}] "
      s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
      s << issue.subject
      @issue = issue
      @users = to_users + cc_users
      @journal = journal
      @journal_details = journal.visible_details(@users.first)
      @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
      mail :to => to_users.map(&:mail),
           :cc => cc_users.map(&:mail),
           :subject => s
    end

    def document_added_with_change(document)
      redmine_headers 'Project' => document.project.identifier
      @author = User.current
      @document = document
      @document_url = url_for(:controller => 'documents', :action => 'show', :id => document)
      mail :to => document.recipients,
           :subject => "[#{document.project.to_s}] #{l(:label_document_new)}: #{document.title}"
    end

    def attachments_added_with_change(attachments)
      container = attachments.first.container
      added_to = ''
      added_to_url = ''
      @author = attachments.first.author
      case container.class.name
        when 'Project'
          added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container)
          added_to = "#{l(:label_project)}: #{container}"
          recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
        when 'Version'
          added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container.project)
          added_to = "#{l(:label_version)}: #{container.name}"
          recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
        when 'Document'
          added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
          added_to = "#{l(:label_document)}: #{container.title}"
          recipients = container.recipients
      end
      redmine_headers 'Project' => container.project.identifier
      @attachments = attachments
      @added_to = added_to
      @added_to_url = added_to_url
      mail :to => recipients,
           :subject => "[#{container.project.to_s}] #{l(:label_attachment_new)}"
    end
    
    def news_added_with_change(news)
      redmine_headers 'Project' => news.project.identifier
      @author = news.author
      message_id news
      references news
      @news = news
      @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
      mail :to => news.recipients,
           :cc => news.cc_for_added_news,
           :subject => "[#{news.project.to_s}] #{l(:label_news)}: #{news.title}"
    end

    # Builds a Mail::Message object used to email recipients of a news' project when a news comment is added.
    #
    # Example:
    #   news_comment_added(comment) => Mail::Message object
    #   Mailer.news_comment_added(comment) => sends an email to the news' project recipients
    def news_comment_added_with_change(comment)
      news = comment.commented
      redmine_headers 'Project' => news.project.identifier
      @author = comment.author
      message_id comment
      references news
      @news = news
      @comment = comment
      @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
      mail :to => news.recipients,
           :cc => news.watcher_recipients,
           :subject => "Re: [#{news.project.to_s}] #{l(:label_news)}: #{news.title}"
    end

    # Builds a Mail::Message object used to email the recipients of the specified message that was posted.
    #
    # Example:
    #   message_posted(message) => Mail::Message object
    #   Mailer.message_posted(message).deliver => sends an email to the recipients
    def message_posted_with_change(message)
      redmine_headers 'Project' => message.project.identifier,
                      'Topic-Id' => (message.parent_id || message.id)
      @author = message.author
      message_id message
      references message.root
      recipients = message.recipients
      cc = ((message.root.watcher_recipients + message.board.watcher_recipients).uniq - recipients)
      @message = message
      @message_url = url_for(message.event_url)
      mail :to => recipients,
           :cc => cc,
           :subject => "[#{message.board.project.to_s} - #{message.board.name} - msg#{message.root.id}] #{message.subject}"
    end

    def wiki_content_added_with_change(wiki_content)
      redmine_headers 'Project' => wiki_content.project.identifier,
                      'Wiki-Page-Id' => wiki_content.page.id
      @author = wiki_content.author
      message_id wiki_content
      recipients = wiki_content.recipients
      cc = wiki_content.page.wiki.watcher_recipients - recipients
      @wiki_content = wiki_content
      @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                  :project_id => wiki_content.project,
                                  :id => wiki_content.page.title)
      mail :to => recipients,
           :cc => cc,
           :subject => "[#{wiki_content.project.to_s}] #{l(:mail_subject_wiki_content_added, :id => wiki_content.page.pretty_title)}"
    end

    def wiki_content_updated_with_change(wiki_content)
      redmine_headers 'Project' => wiki_content.project.identifier,
                      'Wiki-Page-Id' => wiki_content.page.id
      @author = wiki_content.author
      message_id wiki_content
      recipients = wiki_content.recipients
      cc = wiki_content.page.wiki.watcher_recipients + wiki_content.page.watcher_recipients - recipients
      @wiki_content = wiki_content
      @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                  :project_id => wiki_content.project,
                                  :id => wiki_content.page.title)
      @wiki_diff_url = url_for(:controller => 'wiki', :action => 'diff',
                               :project_id => wiki_content.project, :id => wiki_content.page.title,
                               :version => wiki_content.version)
      mail :to => recipients,
           :cc => cc,
           :subject => "[#{wiki_content.project.to_s}] #{l(:mail_subject_wiki_content_updated, :id => wiki_content.page.pretty_title)}"
    end


  end

end


