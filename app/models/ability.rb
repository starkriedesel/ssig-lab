class Ability
  include CanCan::Ability

  def initialize(user_model)
    @user = user_model || User.new # guest user
    
    @user.roles.each { |r| send(r.name) }

    # if there are no roles, then the user may be either a guest or a basic user
    if @user.roles.empty?
      if @user.username.blank?
        guest
      else
        user
      end
    end
  end
  
  # User not logged in
  def guest
    can :read, ChallengeGroup, visible: 1
    can :read, Challenge, challenge_group: {visible: 1}
    can :read, User

    cannot :goto, Challenge
    cannot :complete, Challenge
    cannot :show_hint, Challenge
  end
  
  # Basic user, no roles
  def user
    guest # inherits from guest
    can :goto, Challenge
    can :complete, Challenge
    can :show_hint, Challenge

    # Messages
    #can [:read, :destroy], UserMessage, :user_id=>@user.id
    #can :create, UserMessage
    #cannot :multi_send, UserMessage # Send multiple to multiple users
    #cannot :system_send, UserMessage # Send messages from "System" users
  end
  
  # Site Administrator
  def admin
    user
    can :manage, :all

    # Messages
    #can :multi_send, UserMessage
    #can :system_send, UserMessage
  end
end
