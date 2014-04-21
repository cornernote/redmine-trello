require 'rubygems'
require 'active_resource'
require 'rmt/json_formatter'

module RMT
	class Redmine
		attr_accessor :base_url
		attr_accessor :user
		attr_accessor :password
		
		# Instantiate a redmine client
		#
		# @param [String] base_url the base url (e.g., "https://projects.puppetlabs.com") of the redmine project site to read issues from
		# @param [String] username optional username if authentication is needed.  defaults to nil.
		# @param [String] password optional username if authentication is needed.  defaults to nil.
		def initialize(base_url, username = nil, password = nil)
			@base_url = base_url.sub(/\/$/, "")

			if (username and password)
				@user = username 
				@password = password
			end
			
			Issue.site = @base_url
			Issue.user = @user
			Issue.password = @password
		end

		def GetIssuesByProject(project_id, options = {})
			issues = Issue.find(:all, :params => { :project_id => project_id })
			
			if (options.has_key?(:include_subprojects))
				if (not include_subprojects)
					issues = issues.select { |i| i.project.id == project_id }
				end
			end
			
			return issues
		end
	   
	   def GetIssue(issue_id)					
			issue =  Issue.find(issue_id, :params => {  :include => 'journals,changesets' })			
			issue.link = "#{@base_url}/issues/#{issue_id}"
			
			return issue
	   end
	   
		class Issue < ActiveResource::Base		
			attr_accessor :link
		
			self.format = RMT::JsonFormatter.new(:issues)
		end
	end
end