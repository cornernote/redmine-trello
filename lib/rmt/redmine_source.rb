require 'rmt/redmine'
require 'rmt/synchronization_data'

module RMT
	class RedmineSource
		def initialize(redmine_config)
			@redmine_client = RMT::Redmine.new(redmine_config.base_url,
								 redmine_config.username,
								 redmine_config.password)
			@project_id = redmine_config.project_id
			@check_all_lists = !! redmine_config.check_all_lists
		end

		def data_for(trello, last_run)
			target_list = trello.target_list_id
			issues = @redmine_client.GetIssuesByProject(@project_id)
			
			relevant_cards_loader =
			if @check_all_lists
				proc { |trello| trello.all_cards_on_board_of(target_list) }
			else
				proc { |trello| trello.list_cards_in(target_list) }
			end
			
			issues.collect do |ticket|
				issue = @redmine_client.GetIssue(ticket.id)
				trello_user_id = 
				if issue.attributes['assigned_to']
					trello.user_map[issue.assigned_to.name]
				else
					nil
				end
				
				inotes = 
				if issue.attributes['journals']
					issue.journals.select { |j| Date.parse(j.created_on) > last_run  and (j.attributes["notes"] and not j.notes.empty? ) }					
				else
					nil
				end			
				
				ichangesets = 
				if issue.attributes['changesets']
					issue.changesets.select { |c| Date.parse(c.committed_on) > last_run }
				else
					nil
				end
				
				SynchronizationData.new(
					issue.id,
					issue.subject,
					issue.description,
					target_list,
					trello.color_map[issue.status.name],
					trello_user_id,
					issue.link,
					relevant_cards_loader,
					inotes,
					ichangesets
				)
			end
		end
	end
end

