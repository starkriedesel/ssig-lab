class NavbarCell < Cell::Rails
  #include ChallengeGroup
  include Devise::Controllers::Helpers
  helper_method :user_signed_in?
  helper_method :current_user
  include CanCan::ControllerAdditions
  
  def show
    @nav_links = {
      Home: {url: root_path},
      Register: {url: registration_path, condition: (not user_signed_in?)},
      Challenges: {url: challenge_groups_path, condition: (can? :read, Challenge)},
      Profile: {url: user_signed_in? ? user_path(current_user[:id]) : '', condition: (user_signed_in?)},
      Leaderboard: {url: leaderboard_path, condition: (can? :read, User)}
    }
    
    @nav_links[:Challenges][:sublinks] = {}
    group_filter = ChallengeGroup
    group_filter = group_filter.where('visible = 1')
    group_filter.all.each do |cg|
      @nav_links[:Challenges][:sublinks][cg.name] = {url: challenge_group_path(cg)}
    end
    
    # Check for active links
    @nav_links.each_pair do |name, link|
      checkActive link
      link[:sublinks] = {} if link[:sublinks].nil?
      link[:sublinks].each_pair do |sub_name, sub_link|
        checkActive(sub_link)
      end
    end

    # Check for mail
    @unread_msgs = 0
    if user_signed_in?
      @unread_msgs = UserMessage.unread.where(user_id: current_user.id).count
    end
    
    render
  end
  
  private
  
  def checkActive(link)
    link[:condition] = true if link[:condition].nil?
    link[:active] = true
    if link[:condition]
      Rails.application.routes.recognize_path(link[:url]).each_pair do |condition_name, condition_value|
        if params[condition_name] != condition_value
          link[:active] = false
          break
        end
      end
    end
    link
  end

end
