class Ability
  include CanCan::Ability

  def initialize(user_model)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
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
    can :read, [Challenge, ChallengeGroup, User]
    cannot :show, Challenge
    cannot :complete, Challenge
  end
  
  # Basic user, no roles
  def user
    guest # inherits from guest
    can :show, Challenge
    can :complete, Challenge
  end
  
  # Site Administrator
  def admin
    user
    can :manage, :all
  end
end
