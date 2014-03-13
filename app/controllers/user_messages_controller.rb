class UserMessagesController < ApplicationController
  load_and_authorize_resource

  # GET /user_messages
  def index
    @user_messages = @user_messages.where(:user_id => current_user.id)
  end

  # GET /user_messages/1
  def show
    if not @user_message.read
      @user_message.read = true
      @user_message.save
      @user_message.read = false
    end
  end

  # GET /user_messages/new
  def new
    @user_message_content = UserMessageContent.new
    @user_message_content.user_messages.build
  end

  def reply
    @user_message_content = UserMessageContent.new
    @user_message_content.user_messages.build
    @user_message_content.subject = "RE: "+@user_message.user_message_content.subject
    params[:recipients] = @user_message.user_message_content.user.username
    render action: :new
  end

  # GET /user_messages/1/edit
  def edit
  end

  # POST /user_messages
  def create
    @user_message_content = UserMessageContent.new(params[:user_message_content])
    @user_message_content.user_id = current_user.id

    # Sepaarate recipients by comma, semi-colin, space
    recipients = params[:recipients].split(/[,; ]/)

    # If the user cannot send multi-user messages, give failure
    if recipients.length > 1 and cannot? :multi_send, UserMessage
      render_with_error 'Cannot send multi-user message', :new
      return
    else
      # Remove whitespace from usernames
      recipients = recipients.collect(&:strip)

      # Lookup users by username
      user_lookup = User.select('id,username').where(:username => recipients).all
      non_users = recipients - user_lookup.collect {|u| u.username}

      # If there were unknown users throw error
      if non_users.length > 0
        render_with_error "Cannot find user(s): #{non_users}", :new
        return
      end

      # Attach user to message
      user_lookup.each do |u|
        msg = @user_message_content.user_messages.build
        msg.user_id = u.id
      end
    end

    # Igore from name if user not allowed to send system messages
    if not @user_message_content.from_name.blank? and cannot? :system_send, UserMessage
      @user_message_content.from_name = nil
    end

    if @user_message_content.save
        redirect_to UserMessage, success: 'Message sent successfully'
    else
      flash[:error] = 'Error sending message'
      render action: 'new'
    end
  end

  # DELETE /user_messages/1
  def destroy
    content = @user_message.user_message_content
    if content.user_messages.count < 2
      content.destroy
    else
      @user_message.destroy
    end

    redirect_to user_messages_path
  end
  
  private
  def render_with_error(err_str, action)
    flash[:error] = err_str
    render action: action
  end

  def user_messages_params
    params[:user_message_content]
  end
end
