module ApplicationHelper
  def session_id
    request.session_options[:id]
  end
end
