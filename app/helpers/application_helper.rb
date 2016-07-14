module ApplicationHelper
  def session_id
    request.session_options[:id]
  end

  def nav_links
    links = {
        Home: {url: root_path},
        Register: {url: registration_path, condition: (not user_signed_in?)},
        Challenges: {url: challenge_groups_path, condition: (can? :read, Challenge)},
        Profile: {url: user_signed_in? ? user_path(current_user[:id]) : '', condition: (user_signed_in?)},
        Leaderboard: {url: leaderboard_path, condition: (can? :read, User)},
        'Sign In' => {url: login_path, condition: (!user_signed_in?), class: 'hidden-lg'},
        Admin: {url: nil, condition: (can? :manage, Challenge), sublinks: {Docker: {url: admin_docker_path}}}
    }

    # Create challenges dropdown
    links[:Challenges][:sublinks] = {}
    group_filter = ChallengeGroup
    group_filter = group_filter.where('visible = 1')
    group_filter.all.each do |cg|
      links[:Challenges][:sublinks][cg.name] = {url: challenge_group_path(cg)}
    end

    # Check for active links
    links.each_pair do |name, link|
      check_active link
      link[:sublinks] = {} if link[:sublinks].nil?
      link[:sublinks].each_pair do |sub_name, sub_link|
        check_active sub_link
      end
    end

    links
  end

  def unread_msg_count
    if user_signed_in?
      UserMessage.unread.where(user_id: current_user.id).count
    else
      0
    end
  end

  private

  def check_active(link)
    link[:condition] = true if link[:condition].nil?
    link[:active] = link[:url].nil? ? false : true
    if link[:condition]
      ::Rails.application.routes.recognize_path(link[:url]).each_pair do |condition_name, condition_value|
        if params[condition_name] != condition_value
          link[:active] = false
          break
        end
      end
    end
    link
  end
end
